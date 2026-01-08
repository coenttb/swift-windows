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
public import Kernel_Primitives

#if os(Windows)
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
        /// let (bytes, key, overlapped) = try Kernel.IO.Completion.Port.Dequeue.single(
        ///     port,
        ///     timeout: INFINITE
        /// )
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

    // MARK: - Operations

    extension Kernel.IO.Completion.Port.Dequeue {
        /// Dequeues a single completion packet.
        ///
        /// - Parameters:
        ///   - port: The port handle.
        ///   - timeout: Timeout in milliseconds (`INFINITE` = 0xFFFFFFFF).
        /// - Returns: Tuple of (bytes transferred, completion key, overlapped pointer).
        /// - Throws: `Error.timeout` on timeout, `Error.dequeue` on failure.
        @inlinable
        public static func single(
            _ port: Kernel.Descriptor,
            timeout: DWORD
        ) throws(Kernel.IO.Completion.Port.Error) -> (bytes: DWORD, key: Kernel.IO.Completion.Port.Key, overlapped: LPOVERLAPPED?) {
            var bytes: DWORD = 0
            var key: ULONG_PTR = 0
            var overlapped: LPOVERLAPPED? = nil

            let result = GetQueuedCompletionStatus(
                port.rawValue,
                &bytes,
                &key,
                &overlapped,
                timeout
            )

            if !result {
                let error = GetLastError()
                if error == WAIT_TIMEOUT {
                    throw .timeout
                }
                throw .dequeue(.win32(UInt32(error)))
            }

            return (bytes, Kernel.IO.Completion.Port.Key(rawValue: key), overlapped)
        }

        /// Dequeues multiple completion packets (batch).
        ///
        /// More efficient than calling `single` in a loop when multiple
        /// completions are expected.
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
