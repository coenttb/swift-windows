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

    extension Kernel.IOCP.Read {
        /// Result of initiating an overlapped read operation.
        ///
        /// Windows overlapped I/O can complete either synchronously (immediately)
        /// or asynchronously (later via IOCP). This enum distinguishes the two cases.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// let result = try Kernel.IOCP.read(handle, into: buffer, overlapped: &overlapped)
        /// switch result {
        /// case .pending:
        ///     // Wait for completion via IOCP
        ///     let entry = try Kernel.IOCP.Dequeue.single(port, timeout: INFINITE)
        ///     let bytesRead = entry.0
        /// case .completed(let bytes):
        ///     // Completed immediately, no IOCP notification
        ///     processData(buffer.prefix(Int(bytes)))
        /// }
        /// ```
        ///
        /// ## See Also
        ///
        /// - ``Kernel/IOCP/Write/Result``
        /// - ``Kernel/IOCP/read(_:into:overlapped:)``
        public enum Result: Sendable, Equatable {
            /// The operation is pending asynchronously.
            ///
            /// A completion packet will be posted to the IOCP when the
            /// operation finishes. Do not access the buffer until then.
            case pending

            /// The operation completed synchronously.
            ///
            /// No completion packet will be posted to the IOCP. The data
            /// is immediately available in the buffer.
            case completed(bytes: UInt32)
        }
    }

#endif
