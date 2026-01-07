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

    extension Kernel.IOCP.Write {
        /// Result of initiating an overlapped write operation.
        ///
        /// Windows overlapped I/O can complete either synchronously (immediately)
        /// or asynchronously (later via IOCP). This enum distinguishes the two cases.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// let result = try Kernel.IOCP.write(handle, from: buffer, overlapped: &overlapped)
        /// switch result {
        /// case .pending:
        ///     // Wait for completion via IOCP
        ///     let entry = try Kernel.IOCP.Dequeue.single(port, timeout: INFINITE)
        ///     let bytesWritten = entry.0
        /// case .completed(let bytes):
        ///     // Completed immediately, no IOCP notification
        ///     print("Wrote \(bytes) bytes synchronously")
        /// }
        /// ```
        ///
        /// ## See Also
        ///
        /// - ``Kernel/IOCP/Read/Result``
        /// - ``Kernel/IOCP/write(_:from:overlapped:)``
        public enum Result: Sendable, Equatable {
            /// The operation is pending asynchronously.
            ///
            /// A completion packet will be posted to the IOCP when the
            /// operation finishes.
            case pending

            /// The operation completed synchronously.
            ///
            /// No completion packet will be posted to the IOCP. The data
            /// has already been written.
            case completed(bytes: UInt32)
        }
    }

#endif
