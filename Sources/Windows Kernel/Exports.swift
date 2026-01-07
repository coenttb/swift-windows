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

/// Re-export Kernel namespace from primitives for use within Windows module.
public typealias Kernel = Kernel_Primitives.Kernel

/// Re-export Windows namespace from Windows_Primitives.
public typealias Windows = Windows_Primitives.Windows
