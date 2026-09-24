import UIKit
import ObjectiveC

/// Prepares the NEXT UIKit presentation before its transition begins (NutriKit #3277).
///
/// SwiftUI gives a sheet's content no way to reach its presentation controller until the
/// presentation is already under way: the earliest a view inside it can is `viewWillAppear`,
/// by which time UIKit has laid out where the slide starts. Two things have to be decided
/// before that:
///
/// - **An edge-attached sheet** (`prefersEdgeAttachedInCompactHeight`, which SwiftUI has no
///   modifier for). Set from inside, the slide started from the unattached sheet's frame — the
///   screen's full width — and narrowed to the attached one while it rose, the content sliding
///   sideways with it [recorded on a 17 Pro Max: 10→705 of 717 px at the first frame, 46→670
///   at rest; on the simulator 6→430 of 437 narrowing to 31→405 over a quarter of a second].
/// - **An unanimated cover.** A `fullScreenCover` presented in a transaction that disables
///   animations is still presented `animated: true` [logged], so a cover that animates its own
///   content slid up whole — its scrim a hard-edged block rising from the bottom.
///
/// So whoever raises the presentation says what is coming (`expect`), and the next matching
/// `present` within a second gets it, applied before `present` runs. One swizzle of
/// `UIViewController.present(_:animated:completion:)`, installed on first use; an expectation
/// nothing claims lapses, and one only ever applies to its own kind of presentation.
@MainActor
public enum SheetPresentationPrep {

    public enum Expectation: Sendable {
        /// A sheet, attached to the bottom edge in compact height.
        case edgeAttachedSheet
        /// A full-screen cover, presented without UIKit's slide.
        case unanimatedCover
    }

    /// How long an expectation waits for its presentation. SwiftUI presents in the update the
    /// state change schedules; a second is that with a wide margin.
    private static let lifetime: CFTimeInterval = 1.0

    private static var pending: [Expectation: CFTimeInterval] = [:]
    private static var isInstalled = false

    /// The next presentation of this kind is prepared as described.
    public static func expect(_ expectation: Expectation) {
        installIfNeeded()
        pending[expectation] = CACurrentMediaTime()
    }

    /// Called from the swizzled `present`: applies whatever is expected of this presentation
    /// and returns whether it should still animate.
    fileprivate static func prepare(_ presented: UIViewController, animated: Bool) -> Bool {
        let now = CACurrentMediaTime()
        pending = pending.filter { now - $0.value < lifetime }
        switch presented.modalPresentationStyle {
        case .pageSheet, .formSheet:
            guard pending.removeValue(forKey: .edgeAttachedSheet) != nil,
                  let sheet = presented.sheetPresentationController else { return animated }
            sheet.prefersEdgeAttachedInCompactHeight = true
            return animated
        case .fullScreen, .overFullScreen:
            guard pending.removeValue(forKey: .unanimatedCover) != nil else { return animated }
            return false
        default:
            return animated
        }
    }

    private static func installIfNeeded() {
        guard !isInstalled else { return }
        isInstalled = true
        let cls: AnyClass = UIViewController.self
        guard let original = class_getInstanceMethod(cls, #selector(UIViewController.present(_:animated:completion:))),
              let replacement = class_getInstanceMethod(cls, #selector(UIViewController.glassNumPad_prep_present(_:animated:completion:)))
        else { return }
        method_exchangeImplementations(original, replacement)
    }
}

extension UIViewController {
    /// Swapped with `present(_:animated:completion:)` by `SheetPresentationPrep`: after the
    /// swap, this name runs the original.
    @objc fileprivate func glassNumPad_prep_present(
        _ viewControllerToPresent: UIViewController,
        animated: Bool,
        completion: (() -> Void)?
    ) {
        let animates = SheetPresentationPrep.prepare(viewControllerToPresent, animated: animated)
        glassNumPad_prep_present(viewControllerToPresent, animated: animates, completion: completion)
    }
}
