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

#if os(Windows)
    public import Kernel_Primitives

    extension Kernel.IO {
        /// Completion-related types for asynchronous I/O.
        ///
        /// Contains I/O completion port and related mechanisms.
        public enum Completion {}
    }

#endif
