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

    extension Kernel.IO.Completion.Port.Dequeue {
        #TestSuites
    }

    // MARK: - Unit Tests

    extension Kernel.IO.Completion.Port.Dequeue.Test.Unit {
        @Test("Dequeue namespace exists")
        func namespaceExists() {
            _ = Kernel.IO.Completion.Port.Dequeue.self
        }

        @Test("Dequeue is an enum")
        func isEnum() {
            let _: Kernel.IO.Completion.Port.Dequeue.Type = Kernel.IO.Completion.Port.Dequeue.self
        }
    }

#endif
