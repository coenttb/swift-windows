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

    extension Kernel.IO.Completion.Port.Key {
        #TestSuites
    }

    // MARK: - Unit Tests

    extension Kernel.IO.Completion.Port.Key.Test.Unit {
        @Test("Key type exists")
        func keyExists() {
            _ = Kernel.IO.Completion.Port.Key.self
        }

        @Test("Key conforms to RawRepresentable")
        func isRawRepresentable() {
            let key = Kernel.IO.Completion.Port.Key(rawValue: 42)
            #expect(key.rawValue == 42)
        }

        @Test("Key is Sendable")
        func isSendable() {
            let key: any Sendable = Kernel.IO.Completion.Port.Key(rawValue: 42)
            #expect(key is Kernel.IO.Completion.Port.Key)
        }

        @Test("Key is Equatable")
        func isEquatable() {
            let a = Kernel.IO.Completion.Port.Key(rawValue: 42)
            let b = Kernel.IO.Completion.Port.Key(rawValue: 42)
            let c = Kernel.IO.Completion.Port.Key(rawValue: 99)
            #expect(a == b)
            #expect(a != c)
        }

        @Test("Key is Hashable")
        func isHashable() {
            var set = Set<Kernel.IO.Completion.Port.Key>()
            set.insert(Kernel.IO.Completion.Port.Key(rawValue: 1))
            set.insert(Kernel.IO.Completion.Port.Key(rawValue: 2))
            set.insert(Kernel.IO.Completion.Port.Key(rawValue: 1))  // duplicate
            #expect(set.count == 2)
        }

        @Test("Key.zero is zero")
        func zeroIsZero() {
            #expect(Kernel.IO.Completion.Port.Key.zero.rawValue == 0)
        }

        @Test("Key from integer literal")
        func fromIntegerLiteral() {
            let key: Kernel.IO.Completion.Port.Key = 42
            #expect(key.rawValue == 42)
        }

        @Test("Key from ULONG_PTR")
        func fromULONGPTR() {
            let key = Kernel.IO.Completion.Port.Key(ULONG_PTR(123))
            #expect(key.rawValue == 123)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IO.Completion.Port.Key.Test.EdgeCase {
        @Test("Key with max value")
        func maxValue() {
            let key = Kernel.IO.Completion.Port.Key(rawValue: ULONG_PTR.max)
            #expect(key.rawValue == ULONG_PTR.max)
        }

        @Test("Key with min value")
        func minValue() {
            let key = Kernel.IO.Completion.Port.Key(rawValue: ULONG_PTR.min)
            #expect(key.rawValue == ULONG_PTR.min)
        }
    }

#endif
