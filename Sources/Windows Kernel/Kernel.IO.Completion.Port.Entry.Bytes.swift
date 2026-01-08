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

    extension Kernel.IO.Completion.Port.Entry {
        /// Byte-related properties for completion entry.
        ///
        /// Provides access to byte counts from completed I/O operations.
        public struct Bytes: Sendable {
            @usableFromInline
            let entry: Kernel.IO.Completion.Port.Entry

            @usableFromInline
            init(entry: Kernel.IO.Completion.Port.Entry) {
                self.entry = entry
            }

            /// Number of bytes transferred in the completed operation.
            @inlinable
            public var transferred: Kernel.File.Size {
                Kernel.File.Size(Int64(entry.raw.dwNumberOfBytesTransferred))
            }
        }
    }

#endif
