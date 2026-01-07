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

    extension Kernel.IOCP.Read.Result {
        #TestSuites
    }

    // MARK: - Unit Tests

    extension Kernel.IOCP.Read.Result.Test.Unit {
        @Test("Read.Result type exists")
        func typeExists() {
            let _: Kernel.IOCP.Read.Result.Type = Kernel.IOCP.Read.Result.self
        }

        @Test("Read.Result is an enum")
        func isEnum() {
            let _: Kernel.IOCP.Read.Result.Type = Kernel.IOCP.Read.Result.self
        }
    }

    // MARK: - Case Tests

    extension Kernel.IOCP.Read.Result.Test.Unit {
        @Test("pending case exists")
        func pendingCase() {
            let result = Kernel.IOCP.Read.Result.pending
            if case .pending = result {
                // Expected
            } else {
                Issue.record("Expected .pending case")
            }
        }

        @Test("completed case exists with bytes")
        func completedCase() {
            let result = Kernel.IOCP.Read.Result.completed(bytes: 1024)
            if case .completed(let bytes) = result {
                #expect(bytes == 1024)
            } else {
                Issue.record("Expected .completed case")
            }
        }

        @Test("completed with zero bytes")
        func completedZeroBytes() {
            let result = Kernel.IOCP.Read.Result.completed(bytes: 0)
            if case .completed(let bytes) = result {
                #expect(bytes == 0)
            } else {
                Issue.record("Expected .completed case")
            }
        }

        @Test("completed with maximum bytes")
        func completedMaxBytes() {
            let result = Kernel.IOCP.Read.Result.completed(bytes: UInt32.max)
            if case .completed(let bytes) = result {
                #expect(bytes == UInt32.max)
            } else {
                Issue.record("Expected .completed case")
            }
        }
    }

    // MARK: - Conformance Tests

    extension Kernel.IOCP.Read.Result.Test.Unit {
        @Test("Read.Result is Sendable")
        func isSendable() {
            let value: any Sendable = Kernel.IOCP.Read.Result.pending
            #expect(value is Kernel.IOCP.Read.Result)
        }

        @Test("Read.Result is Equatable")
        func isEquatable() {
            let pending1 = Kernel.IOCP.Read.Result.pending
            let pending2 = Kernel.IOCP.Read.Result.pending
            let completed1 = Kernel.IOCP.Read.Result.completed(bytes: 100)
            let completed2 = Kernel.IOCP.Read.Result.completed(bytes: 100)
            let completed3 = Kernel.IOCP.Read.Result.completed(bytes: 200)

            #expect(pending1 == pending2)
            #expect(completed1 == completed2)
            #expect(pending1 != completed1)
            #expect(completed1 != completed3)
        }
    }

    // MARK: - Pattern Matching Tests

    extension Kernel.IOCP.Read.Result.Test.Unit {
        @Test("switch exhaustively matches all cases")
        func switchExhaustive() {
            let results: [Kernel.IOCP.Read.Result] = [
                .pending,
                .completed(bytes: 0),
                .completed(bytes: 512),
            ]

            for result in results {
                switch result {
                case .pending:
                    break
                case .completed(let bytes):
                    _ = bytes
                }
            }
        }

        @Test("if-case pattern matching works")
        func ifCasePatternMatching() {
            let pending = Kernel.IOCP.Read.Result.pending
            let completed = Kernel.IOCP.Read.Result.completed(bytes: 256)

            if case .pending = pending {
                // Expected
            } else {
                Issue.record("Expected pending")
            }

            if case .completed(let bytes) = completed {
                #expect(bytes == 256)
            } else {
                Issue.record("Expected completed")
            }
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IOCP.Read.Result.Test.EdgeCase {
        @Test("completed with various byte values")
        func completedVariousBytes() {
            let testValues: [UInt32] = [0, 1, 512, 4096, 65536, UInt32.max - 1, UInt32.max]

            for value in testValues {
                let result = Kernel.IOCP.Read.Result.completed(bytes: value)
                if case .completed(let bytes) = result {
                    #expect(bytes == value)
                } else {
                    Issue.record("Expected .completed case for value \(value)")
                }
            }
        }

        @Test("pending cases are always equal")
        func pendingAlwaysEqual() {
            let p1 = Kernel.IOCP.Read.Result.pending
            let p2 = Kernel.IOCP.Read.Result.pending
            let p3 = Kernel.IOCP.Read.Result.pending

            #expect(p1 == p2)
            #expect(p2 == p3)
            #expect(p1 == p3)
        }

        @Test("completed cases with same bytes are equal")
        func completedSameBytesEqual() {
            let c1 = Kernel.IOCP.Read.Result.completed(bytes: 42)
            let c2 = Kernel.IOCP.Read.Result.completed(bytes: 42)

            #expect(c1 == c2)
        }

        @Test("completed cases with different bytes are not equal")
        func completedDifferentBytesNotEqual() {
            let c1 = Kernel.IOCP.Read.Result.completed(bytes: 42)
            let c2 = Kernel.IOCP.Read.Result.completed(bytes: 43)

            #expect(c1 != c2)
        }
    }

#endif
