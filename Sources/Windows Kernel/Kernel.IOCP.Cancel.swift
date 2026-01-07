// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-windows project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//
public import Kernel_Primitives

#if os(Windows)
    public import WinSDK

    extension Kernel.IOCP {
        /// Operations for cancelling pending I/O on IOCP-associated handles.
        ///
        /// Provides both fire-and-forget and status-returning variants for
        /// cancelling all pending operations or specific operations.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// // Cancel all pending I/O on a handle
        /// Kernel.IOCP.Cancel.all(handle)
        ///
        /// // Cancel a specific operation
        /// Kernel.IOCP.Cancel.pending(handle, overlapped: &myOverlapped)
        ///
        /// // Check if cancellation succeeded
        /// if Kernel.IOCP.Cancel.allWithStatus(handle) {
        ///     // Operations were cancelled
        /// }
        /// ```
        ///
        /// ## See Also
        ///
        /// - ``Kernel/IOCP``
        /// - ``Kernel/IOCP/Overlapped``
        public enum Cancel {}
    }

    // MARK: - Cancel All

    extension Kernel.IOCP.Cancel {
        /// Cancels all pending I/O on a handle (fire-and-forget).
        ///
        /// Returns silently if no operations are pending.
        ///
        /// - Parameter descriptor: The descriptor with pending I/O.
        @inlinable
        public static func all(_ descriptor: Kernel.Descriptor) {
            _ = CancelIoEx(descriptor.rawValue, nil)
        }

        /// Cancels all pending I/O on a handle with status.
        ///
        /// - Parameter descriptor: The descriptor with pending I/O.
        /// - Returns: `true` if cancelled, `false` if no pending operations.
        @inlinable
        public static func allWithStatus(_ descriptor: Kernel.Descriptor) -> Bool {
            if CancelIoEx(descriptor.rawValue, nil) {
                return true
            }
            return GetLastError() != Kernel.IOCP.Error.notFound
        }
    }

    // MARK: - Cancel Specific

    extension Kernel.IOCP.Cancel {
        /// Cancels a specific pending I/O operation (fire-and-forget).
        ///
        /// Returns silently if the operation already completed.
        ///
        /// - Parameters:
        ///   - descriptor: The descriptor with pending I/O.
        ///   - overlapped: The overlapped structure for the operation to cancel.
        @inlinable
        public static func pending(
            _ descriptor: Kernel.Descriptor,
            overlapped: inout Kernel.IOCP.Overlapped
        ) {
            withUnsafeMutablePointer(to: &overlapped.raw) { ptr in
                _ = CancelIoEx(descriptor.rawValue, ptr)
            }
        }

        /// Cancels a specific I/O operation with status.
        ///
        /// - Parameters:
        ///   - descriptor: The descriptor with pending I/O.
        ///   - overlapped: The overlapped structure for the operation to cancel.
        /// - Returns: `true` if cancelled, `false` if already completed.
        @inlinable
        public static func pendingWithStatus(
            _ descriptor: Kernel.Descriptor,
            overlapped: inout Kernel.IOCP.Overlapped
        ) -> Bool {
            withUnsafeMutablePointer(to: &overlapped.raw) { ptr in
                if CancelIoEx(descriptor.rawValue, ptr) {
                    return true
                }
                return GetLastError() != Kernel.IOCP.Error.notFound
            }
        }
    }

#endif
