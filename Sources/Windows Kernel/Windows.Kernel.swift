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
public import Windows_Primitives

extension Windows_Primitives.Windows {
    /// Windows kernel mechanisms.
    ///
    /// This is a typealias to `Kernel_Primitives.Kernel`, allowing Windows-specific
    /// extensions to be added to the shared Kernel type.
    ///
    /// Windows-specific mechanisms:
    /// - IOCP (I/O Completion Ports) for async I/O
    public typealias Kernel = Kernel_Primitives.Kernel
}
