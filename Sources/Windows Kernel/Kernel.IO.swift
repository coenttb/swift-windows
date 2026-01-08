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

    extension Kernel {
        /// I/O operations namespace.
        ///
        /// Contains types for asynchronous I/O on Windows, including
        /// completion ports and related mechanisms.
        public enum IO {}
    }

#endif
