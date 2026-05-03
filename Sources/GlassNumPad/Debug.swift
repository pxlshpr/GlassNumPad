import QuartzCore

/// Diagnostic logging hook for the GlassNumPad package.
///
/// The package itself doesn't depend on any logger. Set `log` from the host app
/// (e.g. wire it to `RemoteLogger.shared.debug`) to receive lifecycle events with
/// monotonic timestamps so first-presentation lag can be timed end-to-end.
///
/// Every event is prefixed with `[t=<ms>]` where `<ms>` is the elapsed time since
/// process start (high-precision via `CACurrentMediaTime`). Diff successive lines
/// to find the slow segment.
public enum GlassNumPadDebug {

    /// Set this from the host app to receive log events. Defaults to no-op.
    public nonisolated(unsafe) static var log: (@Sendable (String) -> Void)?

    public static func event(_ message: String) {
        guard let log else { return }
        log("[t=\(timestamp())] \(message)")
    }

    private static let start = CACurrentMediaTime()

    private static func timestamp() -> String {
        let ms = (CACurrentMediaTime() - start) * 1000
        return String(format: "%8.1f", ms)
    }
}
