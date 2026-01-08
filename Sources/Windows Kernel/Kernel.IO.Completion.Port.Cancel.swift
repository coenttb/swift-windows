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

    extension Kernel.IO.Completion.Port {
        /// Operations for cancelling pending I/O on port-associated handles.
        ///
        /// Provides both fire-and-forget and status-returning variants for
        /// cancelling all pending operations or specific operations.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// // Cancel all pending I/O on a handle
        /// Kernel.IO.Completion.Port.Cancel.all(handle)
        ///
        /// // Cancel a specific operation
        /// Kernel.IO.Completion.Port.Cancel.pending(handle, overlapped: &myOverlapped)
        ///
        /// // Check if cancellation succeeded (using nested accessor)
        /// if Kernel.IO.Completion.Port.Cancel.all(handle).status {
        ///     // Operations were cancelled
        /// }
        /// ```
        ///
        /// ## See Also
        ///
        /// - ``Kernel/IO/Completion/Port``
        /// - ``Kernel/IO/Completion/Port/Overlapped``
        public enum Cancel {}
    }

    // MARK: - Cancel All

    extension Kernel.IO.Completion.Port.Cancel {
        /// Result of cancelling all pending I/O operations.
        public struct All: Sendable {
            @usableFromInline
            let descriptor: Kernel.Descriptor

            @usableFromInline
            init(_ descriptor: Kernel.Descriptor) {
                self.descriptor = descriptor
            }

            /// Cancels all pending I/O (fire-and-forget).
            ///
            /// Returns silently if no operations are pending.
            @inlinable
            public func callAsFunction() {
                _ = CancelIoEx(descriptor.rawValue, nil)
            }

            /// Returns whether cancellation succeeded.
            ///
            /// - Returns: `true` if cancelled, `false` if no pending operations.
            @inlinable
            public var status: Bool {
                if CancelIoEx(descriptor.rawValue, nil) {
                    return true
                }
                return GetLastError() != Kernel.IO.Completion.Port.Error.Code.Lookup.notFound
            }
        }

        /// Cancels all pending I/O on a handle.
        ///
        /// - Parameter descriptor: The descriptor with pending I/O.
        /// - Returns: An accessor for cancel operations.
        @inlinable
        public static func all(_ descriptor: Kernel.Descriptor) -> All {
            All(descriptor)
        }
    }

    // MARK: - Cancel Specific

    extension Kernel.IO.Completion.Port.Cancel {
        /// Result of cancelling a specific pending I/O operation.
        public struct Pending: @unchecked Sendable {
            @usableFromInline
            let descriptor: Kernel.Descriptor

            @usableFromInline
            let overlapped: UnsafeMutablePointer<OVERLAPPED>

            @usableFromInline
            init(_ descriptor: Kernel.Descriptor, overlapped: UnsafeMutablePointer<OVERLAPPED>) {
                self.descriptor = descriptor
                self.overlapped = overlapped
            }

            /// Cancels the specific pending I/O (fire-and-forget).
            ///
            /// Returns silently if the operation already completed.
            @inlinable
            public func callAsFunction() {
                _ = CancelIoEx(descriptor.rawValue, overlapped)
            }

            /// Returns whether cancellation succeeded.
            ///
            /// - Returns: `true` if cancelled, `false` if already completed.
            @inlinable
            public var status: Bool {
                if CancelIoEx(descriptor.rawValue, overlapped) {
                    return true
                }
                return GetLastError() != Kernel.IO.Completion.Port.Error.Code.Lookup.notFound
            }
        }

        /// Cancels a specific pending I/O operation.
        ///
        /// - Parameters:
        ///   - descriptor: The descriptor with pending I/O.
        ///   - overlapped: The overlapped structure for the operation to cancel.
        /// - Returns: An accessor for cancel operations.
        @inlinable
        public static func pending(
            _ descriptor: Kernel.Descriptor,
            overlapped: inout Kernel.IO.Completion.Port.Overlapped
        ) -> Pending {
            withUnsafeMutablePointer(to: &overlapped.raw) { ptr in
                Pending(descriptor, overlapped: ptr)
            }
        }
    }

#endif
