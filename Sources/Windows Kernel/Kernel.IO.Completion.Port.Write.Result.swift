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

    extension Kernel.IO.Completion.Port.Write {
        /// Result of initiating an overlapped write operation.
        ///
        /// Windows overlapped I/O can complete either synchronously (immediately)
        /// or asynchronously (later via the port). This enum distinguishes the two cases.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// let result = try Kernel.IO.Completion.Port.write(handle, from: buffer, overlapped: &overlapped)
        /// switch result {
        /// case .pending:
        ///     // Wait for completion via port
        ///     let entry = try Kernel.IO.Completion.Port.Dequeue.single(port, timeout: INFINITE)
        ///     let count = entry.0
        /// case .completed(let bytes):
        ///     // Completed immediately, no port notification
        ///     print("Wrote \(bytes) bytes synchronously")
        /// }
        /// ```
        ///
        /// ## See Also
        ///
        /// - ``Kernel/IO/Completion/Port/Read/Result``
        /// - ``Kernel/IO/Completion/Port/write(_:from:overlapped:)``
        public enum Result: Sendable, Equatable {
            /// The operation is pending asynchronously.
            ///
            /// A completion packet will be posted to the port when the
            /// operation finishes.
            case pending

            /// The operation completed synchronously.
            ///
            /// No completion packet will be posted to the port. The data
            /// has already been written.
            case completed(bytes: UInt32)
        }
    }

#endif
