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

    extension Kernel.IO.Completion.Port.Read {
        /// Result of initiating an overlapped read operation.
        ///
        /// Windows overlapped I/O can complete either synchronously (immediately)
        /// or asynchronously (later via the port). This enum distinguishes the two cases.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// let result = try Kernel.IO.Completion.Port.read(handle, into: buffer, overlapped: &overlapped)
        /// switch result {
        /// case .pending:
        ///     // Wait for completion via port
        ///     let entry = try Kernel.IO.Completion.Port.Dequeue.single(port, timeout: INFINITE)
        ///     let count = entry.0
        /// case .completed(let bytes):
        ///     // Completed immediately, no port notification
        ///     processData(buffer.prefix(Int(bytes)))
        /// }
        /// ```
        ///
        /// ## See Also
        ///
        /// - ``Kernel/IO/Completion/Port/Write/Result``
        /// - ``Kernel/IO/Completion/Port/read(_:into:overlapped:)``
        public enum Result: Sendable, Equatable {
            /// The operation is pending asynchronously.
            ///
            /// A completion packet will be posted to the port when the
            /// operation finishes. Do not access the buffer until then.
            case pending

            /// The operation completed synchronously.
            ///
            /// No completion packet will be posted to the port. The data
            /// is immediately available in the buffer.
            case completed(bytes: UInt32)
        }
    }

#endif
