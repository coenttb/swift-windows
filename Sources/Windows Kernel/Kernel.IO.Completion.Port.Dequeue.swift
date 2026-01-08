// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-windows project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)
public import Kernel_Primitives
    public import WinSDK

    extension Kernel.IO.Completion.Port {
        /// Operations for retrieving completed I/O from a port.
        ///
        /// Provides both single-entry and batch dequeue operations. Batch
        /// dequeuing is more efficient when multiple completions are expected.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// // Single completion
        /// let item = try Kernel.IO.Completion.Port.Dequeue.single(port, timeout: INFINITE)
        /// switch item.status {
        /// case .ok:
        ///     // I/O completed successfully
        ///     print("Transferred \(item.bytes) bytes")
        /// case .platform(let code):
        ///     // I/O failed but was dequeued
        ///     print("Operation failed: \(code)")
        /// }
        ///
        /// // Batch completion (more efficient)
        /// var entries = [OVERLAPPED_ENTRY](repeating: .init(), count: 64)
        /// let count = try entries.withUnsafeMutableBufferPointer { buffer in
        ///     try Kernel.IO.Completion.Port.Dequeue.batch(port, entries: buffer, timeout: 100)
        /// }
        /// ```
        ///
        /// ## See Also
        ///
        /// - ``Kernel/IO/Completion/Port``
        /// - ``Kernel/IO/Completion/Port/Entry``
        /// - ``Kernel/IO/Completion/Port/Key``
        public enum Dequeue {

        }
    }

    // MARK: - Status

    extension Kernel.IO.Completion.Port.Dequeue {
        /// Status of a completed I/O operation.
        @frozen
        public enum Status: Sendable, Equatable {
            /// The I/O operation completed successfully.
            case ok

            /// The I/O operation completed with a platform error.
            case platform(Kernel.Error)
        }
    }

    // MARK: - Item

    extension Kernel.IO.Completion.Port.Dequeue {
        /// A dequeued I/O completion.
        ///
        /// - Important: `overlapped` is a raw pointer and is not memory-safe by itself.
        ///   The associated `OVERLAPPED` storage must remain valid until the completion
        ///   is fully processed. This type is `@unchecked Sendable` for IOCP usage; callers
        ///   must ensure correct lifetime and synchronization of the pointed-to storage.
        @frozen
        public struct Item: @unchecked Sendable {
            /// Number of bytes transferred.
            public let bytes: UInt32

            /// Application-defined completion key.
            public let key: Kernel.IO.Completion.Port.Key

            /// Pointer to the OVERLAPPED structure associated with the operation.
            ///
            /// May be `nil` for synthetic completions posted via `PostQueuedCompletionStatus`
            /// without an associated overlapped structure.
            public let overlapped: UnsafeMutablePointer<OVERLAPPED>?

            /// Status of the completed I/O operation.
            public let status: Status

            @inlinable
            public init(
                bytes: UInt32,
                key: Kernel.IO.Completion.Port.Key,
                overlapped: UnsafeMutablePointer<OVERLAPPED>?,
                status: Status
            ) {
                self.bytes = bytes
                self.key = key
                self.overlapped = overlapped
                self.status = status
            }
        }
    }

    // MARK: - Operations

    extension Kernel.IO.Completion.Port.Dequeue {
        /// Dequeues a single completion packet.
        ///
        /// - Note: This operation **blocks the calling thread** until a completion
        ///   arrives or the timeout expires. For non-blocking polling, use `timeout: 0`.
        ///
        /// - Parameters:
        ///   - port: The port handle.
        ///   - timeout: Timeout in milliseconds (`INFINITE` = 0xFFFFFFFF).
        /// - Returns: The dequeued completion item.
        /// - Throws: `.timeout` on timeout, `.dequeue` only on actual port failure.
        ///   Operation failures are returned via `Item.status`.
        @inlinable
        public static func single(
            _ port: Kernel.Descriptor,
            timeout: DWORD
        ) throws(Kernel.IO.Completion.Port.Error) -> Item {
            var bytes: DWORD = 0
            var key: ULONG_PTR = 0
            var overlapped: LPOVERLAPPED? = nil

            let ok = GetQueuedCompletionStatus(
                port.rawValue,
                &bytes,
                &key,
                &overlapped,
                timeout
            )

            if ok {
                return Item(
                    bytes: UInt32(bytes),
                    key: Kernel.IO.Completion.Port.Key(rawValue: key),
                    overlapped: overlapped,
                    status: .ok
                )
            }

            let error = GetLastError()

            if error == WAIT_TIMEOUT {
                throw .timeout
            }

            if let ov = overlapped {
                // Correct: dequeued completion of a FAILED I/O operation
                return Item(
                    bytes: UInt32(bytes),
                    key: Kernel.IO.Completion.Port.Key(rawValue: key),
                    overlapped: ov,
                    status: .platform(Kernel.Error(code: .win32(error)))
                )
            }

            // Correct: true port-level failure
            throw .dequeue(.win32(error))
        }

        /// Dequeues multiple completion packets (batch).
        ///
        /// More efficient than calling `single` in a loop when multiple
        /// completions are expected.
        ///
        /// - Note: This operation **blocks the calling thread** until at least one
        ///   completion arrives or the timeout expires. For non-blocking polling, use `timeout: 0`.
        ///
        /// - Parameters:
        ///   - port: The port handle.
        ///   - entries: Buffer for completion entries.
        ///   - timeout: Timeout in milliseconds.
        /// - Returns: Number of entries dequeued (0 on timeout).
        /// - Throws: `Error.dequeue` on failure.
        @inlinable
        public static func batch(
            _ port: Kernel.Descriptor,
            entries: UnsafeMutableBufferPointer<OVERLAPPED_ENTRY>,
            timeout: DWORD
        ) throws(Kernel.IO.Completion.Port.Error) -> Int {
            guard let base = entries.baseAddress else { return 0 }

            var removed: ULONG = 0
            let result = GetQueuedCompletionStatusEx(
                port.rawValue,
                base,
                ULONG(entries.count),
                &removed,
                timeout,
                false  // Not alertable
            )

            if !result {
                let error = GetLastError()
                if error == WAIT_TIMEOUT {
                    return 0
                }
                throw .dequeue(.win32(UInt32(error)))
            }

            return Int(removed)
        }
    }

#endif
