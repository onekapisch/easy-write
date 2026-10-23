import Foundation

/// A caller-visible deadline that doesn't await an uncooperative framework task's unwind.
/// Tasks only produce text. Callers own all clipboard, history and UI side effects.
enum RequestDeadline {
    struct Expired: Error {}

    static func stream<T: Sendable>(seconds: Double,
        operation: @escaping @Sendable (AsyncThrowingStream<T, Error>.Continuation) async throws -> Void
    ) -> AsyncThrowingStream<T, Error> {
        AsyncThrowingStream { continuation in
            let work = Task {
                do {
                    try Task.checkCancellation()
                    try await operation(continuation)
                    continuation.finish()
                } catch { continuation.finish(throwing: error) }
            }
            let timer = Task {
                do {
                    try await Task.sleep(nanoseconds: UInt64(max(0, seconds) * 1_000_000_000))
                    continuation.finish(throwing: Expired())
                } catch { /* Normal completion or consumer cancellation stopped the timer. */ }
            }
            continuation.onTermination = { _ in work.cancel(); timer.cancel() }
        }
    }

    static func value<T: Sendable>(seconds: Double,
        operation: @escaping @Sendable () async throws -> T
    ) async throws -> T {
        try Task.checkCancellation()
        let output: AsyncThrowingStream<T, Error> = stream(seconds: seconds) {
            $0.yield(try await operation())
        }
        for try await value in output {
            try Task.checkCancellation()
            return value
        }
        throw CancellationError()
    }
}
