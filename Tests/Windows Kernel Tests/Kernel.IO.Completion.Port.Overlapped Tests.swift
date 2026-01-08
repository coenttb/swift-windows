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

    extension Kernel.IO.Completion.Port.Overlapped {
        #TestSuites
    }

    // MARK: - Unit Tests

    extension Kernel.IO.Completion.Port.Overlapped.Test.Unit {
        @Test("Overlapped type exists")
        func overlappedExists() {
            _ = Kernel.IO.Completion.Port.Overlapped.self
        }

        @Test("Overlapped can be zero-initialized")
        func zeroInitialize() {
            let overlapped = Kernel.IO.Completion.Port.Overlapped()
            _ = overlapped
        }

        @Test("Overlapped offset property exists")
        func offsetExists() {
            var overlapped = Kernel.IO.Completion.Port.Overlapped()
            overlapped.offset = 1234
            #expect(overlapped.offset == 1234)
        }

        @Test("Overlapped offset handles large values")
        func largeOffset() {
            var overlapped = Kernel.IO.Completion.Port.Overlapped()
            let largeValue: Int64 = 0x1_0000_0000  // 4GB
            overlapped.offset = largeValue
            #expect(overlapped.offset == largeValue)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IO.Completion.Port.Overlapped.Test.EdgeCase {
        @Test("Overlapped offset handles max Int64")
        func maxOffset() {
            var overlapped = Kernel.IO.Completion.Port.Overlapped()
            overlapped.offset = Int64.max
            #expect(overlapped.offset == Int64.max)
        }

        @Test("Overlapped offset handles zero")
        func zeroOffset() {
            var overlapped = Kernel.IO.Completion.Port.Overlapped()
            overlapped.offset = 0
            #expect(overlapped.offset == 0)
        }
    }

#endif
