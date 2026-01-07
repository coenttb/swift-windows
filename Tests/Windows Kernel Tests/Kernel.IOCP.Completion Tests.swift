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
    import WinSDK
    import StandardsTestSupport
    import Testing

    @testable import Windows_Kernel
    import Kernel_Primitives

    extension Kernel.IOCP.Completion {
        #TestSuites
    }

    // MARK: - Unit Tests

    extension Kernel.IOCP.Completion.Test.Unit {
        @Test("Completion namespace exists")
        func namespaceExists() {
            _ = Kernel.IOCP.Completion.self
        }

        @Test("Completion is an enum")
        func isEnum() {
            let _: Kernel.IOCP.Completion.Type = Kernel.IOCP.Completion.self
        }
    }

    // MARK: - Nested Types

    extension Kernel.IOCP.Completion.Test.Unit {
        @Test("Completion.Key type exists")
        func keyTypeExists() {
            let _: Kernel.IOCP.Completion.Key.Type = Kernel.IOCP.Completion.Key.self
        }
    }

#endif
