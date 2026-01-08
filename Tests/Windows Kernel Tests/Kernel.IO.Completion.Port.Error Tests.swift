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

    extension Kernel.IO.Completion.Port.Error {
        #TestSuites
    }

    // MARK: - Case Existence Tests

    extension Kernel.IO.Completion.Port.Error.Test.Unit {
        @Test("create case exists")
        func createCase() {
            let code = Kernel.Error.Code.win32(1)
            let error = Kernel.IO.Completion.Port.Error.create(code)
            if case .create(let c) = error {
                #expect(c == code)
            } else {
                Issue.record("Expected .create case")
            }
        }

        @Test("associate case exists")
        func associateCase() {
            let code = Kernel.Error.Code.win32(2)
            let error = Kernel.IO.Completion.Port.Error.associate(code)
            if case .associate(let c) = error {
                #expect(c == code)
            } else {
                Issue.record("Expected .associate case")
            }
        }

        @Test("dequeue case exists")
        func dequeueCase() {
            let code = Kernel.Error.Code.win32(3)
            let error = Kernel.IO.Completion.Port.Error.dequeue(code)
            if case .dequeue(let c) = error {
                #expect(c == code)
            } else {
                Issue.record("Expected .dequeue case")
            }
        }

        @Test("post case exists")
        func postCase() {
            let code = Kernel.Error.Code.win32(4)
            let error = Kernel.IO.Completion.Port.Error.post(code)
            if case .post(let c) = error {
                #expect(c == code)
            } else {
                Issue.record("Expected .post case")
            }
        }

        @Test("read case exists")
        func readCase() {
            let code = Kernel.Error.Code.win32(5)
            let error = Kernel.IO.Completion.Port.Error.read(code)
            if case .read(let c) = error {
                #expect(c == code)
            } else {
                Issue.record("Expected .read case")
            }
        }

        @Test("write case exists")
        func writeCase() {
            let code = Kernel.Error.Code.win32(6)
            let error = Kernel.IO.Completion.Port.Error.write(code)
            if case .write(let c) = error {
                #expect(c == code)
            } else {
                Issue.record("Expected .write case")
            }
        }

        @Test("result case exists")
        func resultCase() {
            let code = Kernel.Error.Code.win32(7)
            let error = Kernel.IO.Completion.Port.Error.result(code)
            if case .result(let c) = error {
                #expect(c == code)
            } else {
                Issue.record("Expected .result case")
            }
        }

        @Test("timeout case exists")
        func timeoutCase() {
            let error = Kernel.IO.Completion.Port.Error.timeout
            if case .timeout = error {
                // Expected
            } else {
                Issue.record("Expected .timeout case")
            }
        }
    }

    // MARK: - Conformance Tests

    extension Kernel.IO.Completion.Port.Error.Test.Unit {
        @Test("Error conforms to Swift.Error")
        func isSwiftError() {
            let error: any Swift.Error = Kernel.IO.Completion.Port.Error.timeout
            #expect(error is Kernel.IO.Completion.Port.Error)
        }

        @Test("Error is Sendable")
        func isSendable() {
            let value: any Sendable = Kernel.IO.Completion.Port.Error.timeout
            #expect(value is Kernel.IO.Completion.Port.Error)
        }

        @Test("Error is Equatable")
        func isEquatable() {
            let a = Kernel.IO.Completion.Port.Error.timeout
            let b = Kernel.IO.Completion.Port.Error.timeout
            let c = Kernel.IO.Completion.Port.Error.create(.win32(1))
            #expect(a == b)
            #expect(a != c)
        }

        @Test("Error is Hashable")
        func isHashable() {
            var set = Set<Kernel.IO.Completion.Port.Error>()
            set.insert(.timeout)
            set.insert(.create(.win32(1)))
            set.insert(.timeout)  // duplicate
            #expect(set.count == 2)
        }
    }

    // MARK: - Description Tests

    extension Kernel.IO.Completion.Port.Error.Test.Unit {
        @Test("create description contains CreateIoCompletionPort")
        func createDescription() {
            let error = Kernel.IO.Completion.Port.Error.create(.win32(5))
            #expect(error.description.contains("CreateIoCompletionPort"))
        }

        @Test("associate description contains associate")
        func associateDescription() {
            let error = Kernel.IO.Completion.Port.Error.associate(.win32(5))
            #expect(error.description.contains("associate"))
        }

        @Test("dequeue description contains GetQueuedCompletionStatus")
        func dequeueDescription() {
            let error = Kernel.IO.Completion.Port.Error.dequeue(.win32(5))
            #expect(error.description.contains("GetQueuedCompletionStatus"))
        }

        @Test("post description contains PostQueuedCompletionStatus")
        func postDescription() {
            let error = Kernel.IO.Completion.Port.Error.post(.win32(5))
            #expect(error.description.contains("PostQueuedCompletionStatus"))
        }

        @Test("read description contains ReadFile")
        func readDescription() {
            let error = Kernel.IO.Completion.Port.Error.read(.win32(5))
            #expect(error.description.contains("ReadFile"))
        }

        @Test("write description contains WriteFile")
        func writeDescription() {
            let error = Kernel.IO.Completion.Port.Error.write(.win32(5))
            #expect(error.description.contains("WriteFile"))
        }

        @Test("result description contains GetOverlappedResult")
        func resultDescription() {
            let error = Kernel.IO.Completion.Port.Error.result(.win32(5))
            #expect(error.description.contains("GetOverlappedResult"))
        }

        @Test("timeout description contains timed out")
        func timeoutDescription() {
            let error = Kernel.IO.Completion.Port.Error.timeout
            #expect(error.description.contains("timed out"))
        }
    }

    // MARK: - last() Helper Tests

    extension Kernel.IO.Completion.Port.Error.Test.Unit {
        @Test("last returns UInt32")
        func lastReturnsUInt32() {
            let lastError = Kernel.IO.Completion.Port.Error.last()
            #expect(lastError is UInt32)
        }
    }

    // MARK: - Code Constants Tests

    extension Kernel.IO.Completion.Port.Error.Test.Unit {
        @Test("Code.IO.pending exists")
        func ioPendingExists() {
            let pending = Kernel.IO.Completion.Port.Error.Code.IO.pending
            #expect(pending is UInt32)
        }

        @Test("Code.Operation.aborted exists")
        func operationAbortedExists() {
            let aborted = Kernel.IO.Completion.Port.Error.Code.Operation.aborted
            #expect(aborted is UInt32)
        }

        @Test("Code.Lookup.notFound exists")
        func lookupNotFoundExists() {
            let notFound = Kernel.IO.Completion.Port.Error.Code.Lookup.notFound
            #expect(notFound is UInt32)
        }

        @Test("Code.Wait.timeout exists")
        func waitTimeoutExists() {
            let timeout = Kernel.IO.Completion.Port.Error.Code.Wait.timeout
            #expect(timeout is UInt32)
        }

        @Test("Code.Wait.infinite exists")
        func waitInfiniteExists() {
            let infinite = Kernel.IO.Completion.Port.Error.Code.Wait.infinite
            #expect(infinite is UInt32)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IO.Completion.Port.Error.Test.EdgeCase {
        @Test("All cases with same code are equal")
        func sameCaseSameCodeEqual() {
            let code = Kernel.Error.Code.win32(42)
            #expect(Kernel.IO.Completion.Port.Error.create(code) == Kernel.IO.Completion.Port.Error.create(code))
            #expect(Kernel.IO.Completion.Port.Error.read(code) == Kernel.IO.Completion.Port.Error.read(code))
        }

        @Test("Different cases with same code are not equal")
        func differentCasesSameCodeNotEqual() {
            let code = Kernel.Error.Code.win32(42)
            #expect(Kernel.IO.Completion.Port.Error.create(code) != Kernel.IO.Completion.Port.Error.read(code))
            #expect(Kernel.IO.Completion.Port.Error.write(code) != Kernel.IO.Completion.Port.Error.result(code))
        }
    }

#endif
