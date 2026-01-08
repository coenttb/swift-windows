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
        /// A completion entry returned by the I/O completion port.
        ///
        /// Represents a single completed I/O operation. When dequeuing completions
        /// in batch, you receive an array of these entries, each containing the
        /// completion key and bytes transferred for one operation.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// var entries = [Kernel.IO.Completion.Port.Entry](repeating: .init(), count: 64)
        /// let count = try Kernel.IO.Completion.Port.Dequeue.batch(
        ///     port,
        ///     entries: &entries,
        ///     timeout: .milliseconds(100)
        /// )
        ///
        /// for i in 0..<count {
        ///     let entry = entries[i]
        ///     let key = entry.key
        ///     let transferred = entry.bytes.transferred
        ///     // Dispatch to handler based on key
        /// }
        /// ```
        ///
        /// ## See Also
        ///
        /// - ``Kernel/IO/Completion/Port``
        /// - ``Kernel/IO/Completion/Port/Key``
        /// - ``Kernel/IO/Completion/Port/Overlapped``
        public struct Entry: @unchecked Sendable {
            /// The underlying Windows OVERLAPPED_ENTRY structure.
            @usableFromInline
            internal var raw: OVERLAPPED_ENTRY

            /// Creates a zero-initialized entry.
            @inlinable
            public init() {
                raw = OVERLAPPED_ENTRY()
            }
        }
    }

    // MARK: - Accessors

    extension Kernel.IO.Completion.Port.Entry {
        /// Pointer to the OVERLAPPED structure for this completion.
        @inlinable
        internal var overlapped: UnsafeMutablePointer<OVERLAPPED>? {
            raw.lpOverlapped
        }

        /// The completion key associated with the file handle.
        @inlinable
        public var key: Kernel.IO.Completion.Port.Key {
            Kernel.IO.Completion.Port.Key(rawValue: raw.lpCompletionKey)
        }
    }

    // MARK: - Bytes Accessor

    extension Kernel.IO.Completion.Port.Entry {
        /// Accessor for byte-related properties.
        public var bytes: Bytes { Bytes(entry: self) }
    }

#endif
