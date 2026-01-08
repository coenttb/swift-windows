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

    extension Kernel.IO.Completion {
        /// Raw I/O Completion Port wrappers (Windows only).
        ///
        /// I/O Completion Ports are the high-performance asynchronous I/O
        /// interface for Windows. This namespace provides policy-free syscall wrappers.
        ///
        /// Higher layers (swift-io) build registration management,
        /// handle tracking, and event dispatch on top of these primitives.
        ///
        /// ## Threading
        ///
        /// All operations in this namespace are **synchronous syscall wrappers**.
        /// They execute on the calling thread and return when the syscall completes.
        ///
        /// - `create`, `associate`, `post`, `close`: Non-blocking syscalls
        /// - `read`, `write`: Initiate async I/O, return immediately (`.pending` or `.completed`)
        /// - `Dequeue.single`, `Dequeue.batch`: **Block** until completion arrives or timeout expires
        public enum Port {

        }
    }

    // MARK: - Syscalls

    extension Kernel.IO.Completion.Port {
        /// Creates a new I/O completion port.
        ///
        /// - Parameter threads: Maximum number of threads allowed to
        ///   concurrently process completions. Pass 0 to use the number of CPUs.
        /// - Returns: The port handle.
        /// - Throws: `Error.create` if creation fails.
        @inlinable
        public static func create(
            threads: UInt32 = 0
        ) throws(Error) -> Kernel.Descriptor {
            let handle = CreateIoCompletionPort(
                INVALID_HANDLE_VALUE,
                nil,
                0,
                DWORD(threads)
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
        ///   - port: The port handle.
        ///   - handle: The file handle to associate.
        ///   - key: Application-defined value returned with completions.
        /// - Throws: `Error.associate` if association fails.
        @inlinable
        public static func associate(
            _ port: Kernel.Descriptor,
            handle: HANDLE,
            key: Key
        ) throws(Error) {
            let result = CreateIoCompletionPort(
                handle,
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
        ///   - port: The port handle.
        ///   - bytes: Number of bytes to report.
        ///   - key: The completion key to return.
        ///   - overlapped: The overlapped pointer to return (can be nil).
        /// - Throws: `Error.post` on failure.
        @inlinable
        public static func post(
            _ port: Kernel.Descriptor,
            bytes: DWORD = 0,
            key: Key = .zero,
            overlapped: LPOVERLAPPED? = nil
        ) throws(Error) {
            let result = PostQueuedCompletionStatus(
                port.rawValue,
                bytes,
                key.rawValue,
                overlapped
            )
            guard result else {
                throw .post(.captureLastError())
            }
        }

        /// Closes the completion port.
        ///
        /// Uses `Kernel.Close.close()` for consistency. This operation is
        /// **fire-and-forget**: errors are ignored. Any threads blocked in
        /// `Dequeue` will receive an error on their next dequeue attempt.
        ///
        /// - Parameter port: The port handle to close.
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
            var count: DWORD = 0
            let success = ReadFile(
                handle,
                buffer.baseAddress,
                DWORD(buffer.count),
                &count,
                overlapped
            )

            if success {
                return .completed(bytes: count)
            }

            let error = GetLastError()
            if error == Error.Code.IO.pending {
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
            var count: DWORD = 0
            let success = WriteFile(
                handle,
                buffer.baseAddress,
                DWORD(buffer.count),
                &count,
                overlapped
            )

            if success {
                return .completed(bytes: count)
            }

            let error = GetLastError()
            if error == Error.Code.IO.pending {
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
            var count: DWORD = 0
            let success = GetOverlappedResult(
                handle,
                overlapped,
                &count,
                wait
            )

            if success {
                return count
            }

            throw .result(.captureLastError())
        }
    }

#endif
