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

    extension Kernel.IO.Completion.Port {
        /// Namespace for read operation types.
        ///
        /// ## See Also
        ///
        /// - ``Kernel/IO/Completion/Port/Read/Result``
        public enum Read {}
    }

#endif
