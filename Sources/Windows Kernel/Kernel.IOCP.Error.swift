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

    extension Kernel.IOCP {
        /// Errors from I/O completion port operations.
        ///
        /// Low-level errors from Windows IOCP operations. Each case wraps
        /// the underlying `Kernel.Error.Code` (Win32 error code) for
        /// platform-specific details. Convert to `Kernel.Error` for
        /// semantic error handling.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// do {
        ///     let port = try Kernel.IOCP.create()
        /// } catch let error as Kernel.IOCP.Error {
        ///     switch error {
        ///     case .create(let code):
        ///         print("CreateIoCompletionPort failed: \(code)")
        ///     case .timeout:
        ///         // Handle timeout
        ///     default:
        ///         throw Kernel.Error(error)  // Convert to semantic error
        ///     }
        /// }
        /// ```
        ///
        /// ## See Also
        ///
        /// - ``Kernel/IOCP``
        /// - ``Kernel/Error``
        /// - ``Kernel/Error/Code``
        public enum Error: Swift.Error, Sendable, Equatable, Hashable {
            /// Failed to create the I/O completion port.
            ///
            /// Returned by `CreateIoCompletionPort` when creating a new port.
            /// Common causes: system resource exhaustion.
            case create(Kernel.Error.Code)

            /// Failed to associate a handle with the IOCP.
            ///
            /// Returned by `CreateIoCompletionPort` when associating a handle.
            /// Common causes: handle already associated, invalid handle.
            case associate(Kernel.Error.Code)

            /// Failed to dequeue completion entries.
            ///
            /// Returned by `GetQueuedCompletionStatus[Ex]`. May indicate
            /// the port was closed or an invalid handle was used.
            case dequeue(Kernel.Error.Code)

            /// Failed to post a completion packet.
            ///
            /// Returned by `PostQueuedCompletionStatus`. May indicate
            /// the port is invalid or full.
            case post(Kernel.Error.Code)

            /// Failed to initiate an asynchronous read.
            ///
            /// Returned by `ReadFile` when the async operation could not
            /// be started. Does not include `ERROR_IO_PENDING` (which is normal).
            case read(Kernel.Error.Code)

            /// Failed to initiate an asynchronous write.
            ///
            /// Returned by `WriteFile` when the async operation could not
            /// be started. Does not include `ERROR_IO_PENDING` (which is normal).
            case write(Kernel.Error.Code)

            /// Failed to get the result of an overlapped operation.
            ///
            /// Returned by `GetOverlappedResult` when the operation
            /// failed or the parameters were invalid.
            case result(Kernel.Error.Code)

            /// The wait operation timed out.
            ///
            /// Returned when `GetQueuedCompletionStatus[Ex]` times out
            /// without receiving any completion packets.
            case timeout
        }
    }

    // MARK: - CustomStringConvertible

    extension Kernel.IOCP.Error: CustomStringConvertible {
        public var description: String {
            switch self {
            case .create(let code):
                return "CreateIoCompletionPort failed (\(code))"
            case .associate(let code):
                return "associate failed (\(code))"
            case .dequeue(let code):
                return "GetQueuedCompletionStatus failed (\(code))"
            case .post(let code):
                return "PostQueuedCompletionStatus failed (\(code))"
            case .read(let code):
                return "ReadFile failed (\(code))"
            case .write(let code):
                return "WriteFile failed (\(code))"
            case .result(let code):
                return "GetOverlappedResult failed (\(code))"
            case .timeout:
                return "operation timed out"
            }
        }
    }

    // MARK: - Last Error Helper

    extension Kernel.IOCP.Error {
        /// Gets the last Windows error code.
        ///
        /// Exposed so swift-io doesn't need to import WinSDK.
        @inlinable
        public static func last() -> UInt32 {
            GetLastError()
        }
    }

    // MARK: - Windows Error Code Constants

    extension Kernel.IOCP.Error {
        /// The I/O operation has been started but not yet completed.
        ///
        /// This is the normal return code for an asynchronous operation
        /// that was successfully queued. A completion packet will be
        /// posted to the IOCP when the operation finishes.
        ///
        /// - Win32: `ERROR_IO_PENDING`
        public static let ioPending: UInt32 = UInt32(ERROR_IO_PENDING)

        /// The I/O operation was aborted due to cancellation.
        ///
        /// Returned when an overlapped operation is cancelled via
        /// `CancelIo` or `CancelIoEx`.
        ///
        /// - Win32: `ERROR_OPERATION_ABORTED`
        public static let operationAborted: UInt32 = UInt32(ERROR_OPERATION_ABORTED)

        /// The specified operation was not found.
        ///
        /// Returned when attempting to cancel an operation that doesn't exist.
        ///
        /// - Win32: `ERROR_NOT_FOUND`
        public static let notFound: UInt32 = UInt32(ERROR_NOT_FOUND)

        /// The wait operation timed out.
        ///
        /// Returned by `GetQueuedCompletionStatus[Ex]` when the timeout
        /// expires without receiving a completion packet.
        ///
        /// - Win32: `WAIT_TIMEOUT`
        public static let waitTimeout: UInt32 = UInt32(bitPattern: WAIT_TIMEOUT)

        /// Infinite timeout value.
        ///
        /// Pass to timeout parameters to wait indefinitely.
        ///
        /// - Win32: `INFINITE`
        public static let infinite: UInt32 = INFINITE
    }

#endif
