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

    extension Kernel.IOCP.Overlapped {
        #TestSuites
    }

    // MARK: - Unit Tests

    extension Kernel.IOCP.Overlapped.Test.Unit {
        @Test("Overlapped type exists")
        func typeExists() {
            let _: Kernel.IOCP.Overlapped.Type = Kernel.IOCP.Overlapped.self
        }

        @Test("Overlapped default init creates zero-initialized structure")
        func defaultInit() {
            let overlapped = Kernel.IOCP.Overlapped()
            #expect(overlapped.offset == 0)
        }
    }

    // MARK: - Offset Tests

    extension Kernel.IOCP.Overlapped.Test.Unit {
        @Test("offset get returns combined 64-bit value")
        func offsetGet() {
            var overlapped = Kernel.IOCP.Overlapped()
            overlapped.raw.Offset = 0xDEAD_BEEF
            overlapped.raw.OffsetHigh = 0x1234_5678

            let expected: Int64 = Int64(0x1234_5678) << 32 | Int64(0xDEAD_BEEF)
            #expect(overlapped.offset == expected)
        }

        @Test("offset set splits into low and high parts")
        func offsetSet() {
            var overlapped = Kernel.IOCP.Overlapped()
            let testOffset: Int64 = 0x1234_5678_9ABC_DEF0

            overlapped.offset = testOffset

            #expect(overlapped.raw.Offset == 0x9ABC_DEF0)
            #expect(overlapped.raw.OffsetHigh == 0x1234_5678)
        }

        @Test("offset roundtrip preserves value")
        func offsetRoundtrip() {
            var overlapped = Kernel.IOCP.Overlapped()

            let testValues: [Int64] = [
                0,
                1,
                Int64.max,
                0x7FFF_FFFF_FFFF_FFFF,
                0x0000_0001_0000_0000,
                0x0000_0000_FFFF_FFFF,
            ]

            for value in testValues {
                overlapped.offset = value
                #expect(overlapped.offset == value)
            }
        }

        @Test("offset zero")
        func offsetZero() {
            var overlapped = Kernel.IOCP.Overlapped()
            overlapped.offset = 0
            #expect(overlapped.offset == 0)
            #expect(overlapped.raw.Offset == 0)
            #expect(overlapped.raw.OffsetHigh == 0)
        }
    }

    // MARK: - Conformance Tests

    extension Kernel.IOCP.Overlapped.Test.Unit {
        @Test("Overlapped is Sendable")
        func isSendable() {
            let value: any Sendable = Kernel.IOCP.Overlapped()
            #expect(value is Kernel.IOCP.Overlapped)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IOCP.Overlapped.Test.EdgeCase {
        @Test("offset handles 32-bit boundary values")
        func offsetBoundaryValues() {
            var overlapped = Kernel.IOCP.Overlapped()

            // Maximum 32-bit value (only low part used)
            overlapped.offset = 0xFFFF_FFFF
            #expect(overlapped.raw.Offset == 0xFFFF_FFFF)
            #expect(overlapped.raw.OffsetHigh == 0)
            #expect(overlapped.offset == 0xFFFF_FFFF)

            // Minimum value for high part
            overlapped.offset = 0x1_0000_0000
            #expect(overlapped.raw.Offset == 0)
            #expect(overlapped.raw.OffsetHigh == 1)
            #expect(overlapped.offset == 0x1_0000_0000)
        }

        @Test("offset handles maximum positive Int64")
        func offsetMaxPositive() {
            var overlapped = Kernel.IOCP.Overlapped()
            overlapped.offset = Int64.max

            // Int64.max = 0x7FFFFFFFFFFFFFFF
            #expect(overlapped.raw.Offset == 0xFFFF_FFFF)
            #expect(overlapped.raw.OffsetHigh == 0x7FFF_FFFF)
            #expect(overlapped.offset == Int64.max)
        }

        @Test("offset set and get are consistent")
        func offsetConsistency() {
            var overlapped = Kernel.IOCP.Overlapped()

            // Set via property, verify raw fields match expected split
            // Use bitPattern since the hex value exceeds Int64.max
            let testValue: UInt64 = 0xABCD_EF01_2345_6789
            overlapped.offset = Int64(bitPattern: testValue)

            // Note: This value is negative when interpreted as signed
            // but the bit pattern should be preserved
            let expectedLow = DWORD(truncatingIfNeeded: testValue)
            let expectedHigh = DWORD(truncatingIfNeeded: testValue >> 32)

            #expect(overlapped.raw.Offset == expectedLow)
            #expect(overlapped.raw.OffsetHigh == expectedHigh)
        }

        @Test("multiple overlapped instances are independent")
        func multipleInstances() {
            var a = Kernel.IOCP.Overlapped()
            var b = Kernel.IOCP.Overlapped()

            a.offset = 100
            b.offset = 200

            #expect(a.offset == 100)
            #expect(b.offset == 200)

            a.offset = 300
            #expect(a.offset == 300)
            #expect(b.offset == 200)
        }
    }

    // MARK: - Memory Layout Tests

    extension Kernel.IOCP.Overlapped.Test.Unit {
        @Test("Overlapped has correct memory layout for Windows interop")
        func memoryLayout() {
            // The wrapper should have the same layout as OVERLAPPED
            // to allow container-of pattern
            #expect(MemoryLayout<Kernel.IOCP.Overlapped>.size >= MemoryLayout<OVERLAPPED>.size)
        }
    }

#endif
