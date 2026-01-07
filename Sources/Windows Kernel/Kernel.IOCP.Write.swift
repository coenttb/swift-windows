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

    extension Kernel.IOCP {
        /// Namespace for write operation types.
        ///
        /// ## See Also
        ///
        /// - ``Kernel/IOCP/Write/Result``
        public enum Write {}
    }

#endif
