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

    extension Kernel.IOCP {
        /// Namespace for completion-related types.
        ///
        /// Contains types used for identifying and routing completed
        /// I/O operations, such as completion keys.
        ///
        /// ## See Also
        ///
        /// - ``Kernel/IOCP``
        /// - ``Kernel/IOCP/Completion/Key``
        public enum Completion {}
    }

#endif
