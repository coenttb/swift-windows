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
    import StandardsTestSupport
    import Testing

    @testable import Windows_Kernel
    import Kernel_Primitives

    extension Kernel.IO.Completion.Port.Read.Result {
        #TestSuites
    }

    // MARK: - Unit Tests

    extension Kernel.IO.Completion.Port.Read.Result.Test.Unit {
        @Test("Result type exists")
        func resultExists() {
            _ = Kernel.IO.Completion.Port.Read.Result.self
        }

        @Test("Result has pending case")
        func pendingCase() {
            let result = Kernel.IO.Completion.Port.Read.Result.pending
            if case .pending = result {
                // Expected
            } else {
                Issue.record("Expected .pending case")
            }
        }

        @Test("Result has completed case")
        func completedCase() {
            let result = Kernel.IO.Completion.Port.Read.Result.completed(bytes: 100)
            if case .completed(let bytes) = result {
                #expect(bytes == 100)
            } else {
                Issue.record("Expected .completed case")
            }
        }

        @Test("Result is Sendable")
        func isSendable() {
            let result: any Sendable = Kernel.IO.Completion.Port.Read.Result.pending
            #expect(result is Kernel.IO.Completion.Port.Read.Result)
        }

        @Test("Result is Equatable")
        func isEquatable() {
            let a = Kernel.IO.Completion.Port.Read.Result.pending
            let b = Kernel.IO.Completion.Port.Read.Result.pending
            let c = Kernel.IO.Completion.Port.Read.Result.completed(bytes: 0)
            #expect(a == b)
            #expect(a != c)
        }
    }

#endif
