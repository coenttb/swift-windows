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

    extension Kernel.IOCP.Completion.Key {
        #TestSuites
    }

    // MARK: - Unit Tests

    extension Kernel.IOCP.Completion.Key.Test.Unit {
        @Test("Key type exists")
        func typeExists() {
            let _: Kernel.IOCP.Completion.Key.Type = Kernel.IOCP.Completion.Key.self
        }

        @Test("Key from rawValue")
        func fromRawValue() {
            let key = Kernel.IOCP.Completion.Key(rawValue: 42)
            #expect(key.rawValue == 42)
        }

        @Test("Key from ULONG_PTR")
        func fromULONGPTR() {
            let key = Kernel.IOCP.Completion.Key(100)
            #expect(key.rawValue == 100)
        }

        @Test("Key.zero constant")
        func zeroConstant() {
            let zero = Kernel.IOCP.Completion.Key.zero
            #expect(zero.rawValue == 0)
        }
    }

    // MARK: - Pointer Conversion Tests

    extension Kernel.IOCP.Completion.Key.Test.Unit {
        @Test("Key from UnsafeRawPointer")
        func fromRawPointer() {
            var value: Int = 42
            withUnsafePointer(to: &value) { ptr in
                let key = Kernel.IOCP.Completion.Key(ptr)
                #expect(key.rawValue == ULONG_PTR(UInt(bitPattern: ptr)))
            }
        }

        @Test("Key from typed pointer")
        func fromTypedPointer() {
            var value: Int = 42
            withUnsafePointer(to: &value) { ptr in
                let key = Kernel.IOCP.Completion.Key(pointer: ptr)
                #expect(key.rawValue == ULONG_PTR(UInt(bitPattern: ptr)))
            }
        }

        @Test("Key from mutable typed pointer")
        func fromMutableTypedPointer() {
            var value: Int = 42
            withUnsafeMutablePointer(to: &value) { ptr in
                let key = Kernel.IOCP.Completion.Key(pointer: ptr)
                #expect(key.rawValue == ULONG_PTR(UInt(bitPattern: ptr)))
            }
        }
    }

    // MARK: - ExpressibleByIntegerLiteral Tests

    extension Kernel.IOCP.Completion.Key.Test.Unit {
        @Test("Key from integer literal")
        func fromIntegerLiteral() {
            let key: Kernel.IOCP.Completion.Key = 256
            #expect(key.rawValue == 256)
        }
    }

    // MARK: - Conformance Tests

    extension Kernel.IOCP.Completion.Key.Test.Unit {
        @Test("Key is Sendable")
        func isSendable() {
            let value: any Sendable = Kernel.IOCP.Completion.Key.zero
            #expect(value is Kernel.IOCP.Completion.Key)
        }

        @Test("Key is Equatable")
        func isEquatable() {
            let a = Kernel.IOCP.Completion.Key(100)
            let b = Kernel.IOCP.Completion.Key(100)
            let c = Kernel.IOCP.Completion.Key(200)
            #expect(a == b)
            #expect(a != c)
        }

        @Test("Key is Hashable")
        func isHashable() {
            var set = Set<Kernel.IOCP.Completion.Key>()
            set.insert(.zero)
            set.insert(Kernel.IOCP.Completion.Key(1))
            set.insert(.zero)  // duplicate
            #expect(set.count == 2)
        }

        @Test("Key is RawRepresentable")
        func isRawRepresentable() {
            let key = Kernel.IOCP.Completion.Key(rawValue: 42)
            #expect(key.rawValue == 42)
        }
    }

    // MARK: - Integration Tests

    extension Kernel.IOCP.Completion.Key.Test.Unit {
        @Test("Key roundtrips through IOCP post/dequeue")
        func keyRoundtripsThoughIOCP() throws {
            let port = try Kernel.IOCP.create()
            defer { Kernel.IOCP.close(port) }

            let originalKey = Kernel.IOCP.Completion.Key(0xDEAD_BEEF)
            try Kernel.IOCP.post(port, key: originalKey)

            let result = try Kernel.IOCP.Dequeue.single(port, timeout: 1000)
            #expect(result.key == originalKey)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IOCP.Completion.Key.Test.EdgeCase {
        @Test("Key max value")
        func maxValue() {
            let key = Kernel.IOCP.Completion.Key(rawValue: ULONG_PTR.max)
            #expect(key.rawValue == ULONG_PTR.max)
        }

        @Test("Key rawValue roundtrip")
        func rawValueRoundtrip() {
            let values: [ULONG_PTR] = [0, 1, 100, 0xDEAD_BEEF, ULONG_PTR.max]
            for value in values {
                let key = Kernel.IOCP.Completion.Key(rawValue: value)
                #expect(key.rawValue == value)
            }
        }

        @Test("pointer-based key preserves bit pattern")
        func pointerKeyPreservesBitPattern() {
            var values = [Int](repeating: 0, count: 10)
            for i in 0..<values.count {
                withUnsafePointer(to: &values[i]) { ptr in
                    let key = Kernel.IOCP.Completion.Key(ptr)
                    // Can reconstruct the pointer from the key
                    let reconstructed = UnsafeRawPointer(bitPattern: UInt(key.rawValue))
                    #expect(reconstructed == UnsafeRawPointer(ptr))
                }
            }
        }
    }

#endif
