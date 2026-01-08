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

    extension Kernel.IO.Completion.Port {
        /// Tracks the state of an asynchronous I/O operation on Windows.
        ///
        /// Every asynchronous I/O operation requires an `OVERLAPPED` structure
        /// to track its state. The structure must remain valid until the
        /// operation completes. Common patterns embed this in a larger struct
        /// to associate application state with the operation.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// var overlapped = Kernel.IO.Completion.Port.Overlapped()
        /// overlapped.offset = position
        ///
        /// // Start async read (overlapped must stay alive until completion)
        /// try Kernel.IO.Completion.Port.read(
        ///     handle,
        ///     buffer: buffer,
        ///     overlapped: &overlapped
        /// )
        ///
        /// // Later, retrieve completion
        /// let entry = try Kernel.IO.Completion.Port.Dequeue.single(port, timeout: .infinite)
        /// let count = entry.bytes.transferred
        /// ```
        ///
        /// ## Container-Of Pattern
        ///
        /// For associating state with operations, embed `Overlapped` as the
        /// first field of a struct:
        ///
        /// ```swift
        /// struct MyOperation {
        ///     var overlapped: Kernel.IO.Completion.Port.Overlapped
        ///     var buffer: [UInt8]
        ///     var callback: (Int) -> Void
        /// }
        /// ```
        ///
        /// ## See Also
        ///
        /// - ``Kernel/IO/Completion/Port``
        /// - ``Kernel/IO/Completion/Port/Entry``
        public struct Overlapped: @unchecked Sendable {
            /// The underlying Windows OVERLAPPED structure.
            @usableFromInline
            internal var raw: OVERLAPPED

            /// Creates a zero-initialized overlapped structure.
            @inlinable
            public init() {
                raw = OVERLAPPED()
            }
        }
    }

    // MARK: - Accessors

    extension Kernel.IO.Completion.Port.Overlapped {
        /// The 64-bit file offset for positioned I/O.
        @inlinable
        public var offset: Int64 {
            get { Int64(raw.Offset) | (Int64(raw.OffsetHigh) << 32) }
            set {
                raw.Offset = DWORD(truncatingIfNeeded: newValue)
                raw.OffsetHigh = DWORD(truncatingIfNeeded: newValue >> 32)
            }
        }
    }

#endif
