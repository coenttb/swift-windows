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

    extension Kernel.IO.Completion.Port.Entry {
        #TestSuites
    }

    // MARK: - Unit Tests

    extension Kernel.IO.Completion.Port.Entry.Test.Unit {
        @Test("Entry type exists")
        func entryExists() {
            _ = Kernel.IO.Completion.Port.Entry.self
        }

        @Test("Entry can be zero-initialized")
        func zeroInitialize() {
            let entry = Kernel.IO.Completion.Port.Entry()
            _ = entry
        }

        @Test("Entry.Bytes type exists")
        func bytesExists() {
            _ = Kernel.IO.Completion.Port.Entry.Bytes.self
        }

        @Test("Entry has bytes accessor")
        func hasBytesAccessor() {
            let entry = Kernel.IO.Completion.Port.Entry()
            _ = entry.bytes
        }

        @Test("Entry has key accessor")
        func hasKeyAccessor() {
            let entry = Kernel.IO.Completion.Port.Entry()
            _ = entry.key
        }
    }

#endif
