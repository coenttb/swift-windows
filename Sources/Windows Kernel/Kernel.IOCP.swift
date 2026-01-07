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

    extension Kernel {
        /// Raw IOCP (I/O Completion Ports) wrappers (Windows only).
        ///
        /// IOCP is the high-performance asynchronous I/O interface for Windows.
        /// This namespace provides policy-free syscall wrappers.
        ///
        /// Higher layers (swift-io) build registration management,
        /// handle tracking, and event dispatch on top of these primitives.
        public enum IOCP {

        }
    }

    // MARK: - Syscalls

    extension Kernel.IOCP {
        /// Creates a new I/O completion port.
        ///
        /// - Parameter concurrentThreads: Maximum number of threads allowed to
        ///   concurrently process completions. Pass 0 to use the number of CPUs.
        /// - Returns: The IOCP handle.
        /// - Throws: `Error.create` if creation fails.
        @inlinable
        public static func create(
            concurrentThreads: UInt32 = 0
        ) throws(Error) -> Kernel.Descriptor {
            let handle = CreateIoCompletionPort(
                INVALID_HANDLE_VALUE,
                nil,
                0,
                DWORD(concurrentThreads)
            )
            guard let handle, handle != INVALID_HANDLE_VALUE else {
                throw .create(.captureLastError())
            }
            return Kernel.Descriptor(rawValue: handle)
        }

        /// Associates a file handle with the completion port.
        ///
        /// The file handle must have been opened with `FILE_FLAG_OVERLAPPED`.
        ///
        /// - Parameters:
        ///   - port: The IOCP handle.
        ///   - fileHandle: The file handle to associate.
        ///   - key: Application-defined value returned with completions.
        /// - Throws: `Error.associate` if association fails.
        @inlinable
        public static func associate(
            _ port: Kernel.Descriptor,
            fileHandle: HANDLE,
            key: Completion.Key
        ) throws(Error) {
            let result = CreateIoCompletionPort(
                fileHandle,
                port.rawValue,
                key.rawValue,
                0
            )
            guard result != nil else {
                throw .associate(.captureLastError())
            }
        }

        /// Posts a completion packet to the port.
        ///
        /// This can be used to wake up a thread waiting on the port,
        /// or to manually signal completion of an operation.
        ///
        /// - Parameters:
        ///   - port: The IOCP handle.
        ///   - bytesTransferred: Number of bytes to report.
        ///   - key: The completion key to return.
        ///   - overlapped: The overlapped pointer to return (can be nil).
        /// - Throws: `Error.post` on failure.
        @inlinable
        public static func post(
            _ port: Kernel.Descriptor,
            bytesTransferred: DWORD = 0,
            key: Completion.Key = .zero,
            overlapped: LPOVERLAPPED? = nil
        ) throws(Error) {
            let result = PostQueuedCompletionStatus(
                port.rawValue,
                bytesTransferred,
                key.rawValue,
                overlapped
            )
            guard result else {
                throw .post(.captureLastError())
            }
        }

        /// Closes the completion port.
        ///
        /// Uses `Kernel.Close.close()` for consistency. Ignores errors.
        ///
        /// - Parameter port: The IOCP handle to close.
        @inlinable
        public static func close(_ port: Kernel.Descriptor) {
            try? Kernel.Close.close(port)
        }

        /// Initiates an overlapped read operation.
        ///
        /// - Parameters:
        ///   - handle: The file handle (must be opened with FILE_FLAG_OVERLAPPED).
        ///   - buffer: The buffer to read into.
        ///   - overlapped: The overlapped structure for this operation.
        /// - Returns: `.pending` if async, `.completed(bytes:)` if sync completion.
        /// - Throws: `Error.read` on failure (excluding ERROR_IO_PENDING).
        @inlinable
        public static func read(
            _ handle: HANDLE,
            into buffer: UnsafeMutableRawBufferPointer,
            overlapped: UnsafeMutablePointer<OVERLAPPED>
        ) throws(Error) -> Read.Result {
            var bytesRead: DWORD = 0
            let success = ReadFile(
                handle,
                buffer.baseAddress,
                DWORD(buffer.count),
                &bytesRead,
                overlapped
            )

            if success {
                return .completed(bytes: bytesRead)
            }

            let error = GetLastError()
            if error == Error.ioPending {
                return .pending
            }

            throw .read(.win32(UInt32(error)))
        }

        /// Initiates an overlapped write operation.
        ///
        /// - Parameters:
        ///   - handle: The file handle (must be opened with FILE_FLAG_OVERLAPPED).
        ///   - buffer: The buffer to write from.
        ///   - overlapped: The overlapped structure for this operation.
        /// - Returns: `.pending` if async, `.completed(bytes:)` if sync completion.
        /// - Throws: `Error.write` on failure (excluding ERROR_IO_PENDING).
        @inlinable
        public static func write(
            _ handle: HANDLE,
            from buffer: UnsafeRawBufferPointer,
            overlapped: UnsafeMutablePointer<OVERLAPPED>
        ) throws(Error) -> Write.Result {
            var bytesWritten: DWORD = 0
            let success = WriteFile(
                handle,
                buffer.baseAddress,
                DWORD(buffer.count),
                &bytesWritten,
                overlapped
            )

            if success {
                return .completed(bytes: bytesWritten)
            }

            let error = GetLastError()
            if error == Error.ioPending {
                return .pending
            }

            throw .write(.win32(UInt32(error)))
        }

        /// Gets the result of a completed overlapped operation.
        ///
        /// - Parameters:
        ///   - handle: The file handle.
        ///   - overlapped: The overlapped structure.
        ///   - wait: If `true`, blocks until the operation completes.
        /// - Returns: The number of bytes transferred.
        /// - Throws: `Error.result` on failure.
        @inlinable
        public static func result(
            _ handle: HANDLE,
            overlapped: UnsafeMutablePointer<OVERLAPPED>,
            wait: Bool = false
        ) throws(Error) -> UInt32 {
            var bytesTransferred: DWORD = 0
            let success = GetOverlappedResult(
                handle,
                overlapped,
                &bytesTransferred,
                wait
            )

            if success {
                return bytesTransferred
            }

            throw .result(.captureLastError())
        }
    }

#endif
