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

    extension Kernel.IOCP.Error {
        #TestSuites
    }

    // MARK: - Case Existence Tests

    extension Kernel.IOCP.Error.Test.Unit {
        @Test("create case exists")
        func createCase() {
            let code = Kernel.Error.Code.win32(1)
            let error = Kernel.IOCP.Error.create(code)
            if case .create(let c) = error {
                #expect(c == code)
            } else {
                Issue.record("Expected .create case")
            }
        }

        @Test("associate case exists")
        func associateCase() {
            let code = Kernel.Error.Code.win32(2)
            let error = Kernel.IOCP.Error.associate(code)
            if case .associate(let c) = error {
                #expect(c == code)
            } else {
                Issue.record("Expected .associate case")
            }
        }

        @Test("dequeue case exists")
        func dequeueCase() {
            let code = Kernel.Error.Code.win32(3)
            let error = Kernel.IOCP.Error.dequeue(code)
            if case .dequeue(let c) = error {
                #expect(c == code)
            } else {
                Issue.record("Expected .dequeue case")
            }
        }

        @Test("post case exists")
        func postCase() {
            let code = Kernel.Error.Code.win32(4)
            let error = Kernel.IOCP.Error.post(code)
            if case .post(let c) = error {
                #expect(c == code)
            } else {
                Issue.record("Expected .post case")
            }
        }

        @Test("read case exists")
        func readCase() {
            let code = Kernel.Error.Code.win32(5)
            let error = Kernel.IOCP.Error.read(code)
            if case .read(let c) = error {
                #expect(c == code)
            } else {
                Issue.record("Expected .read case")
            }
        }

        @Test("write case exists")
        func writeCase() {
            let code = Kernel.Error.Code.win32(6)
            let error = Kernel.IOCP.Error.write(code)
            if case .write(let c) = error {
                #expect(c == code)
            } else {
                Issue.record("Expected .write case")
            }
        }

        @Test("result case exists")
        func resultCase() {
            let code = Kernel.Error.Code.win32(7)
            let error = Kernel.IOCP.Error.result(code)
            if case .result(let c) = error {
                #expect(c == code)
            } else {
                Issue.record("Expected .result case")
            }
        }

        @Test("timeout case exists")
        func timeoutCase() {
            let error = Kernel.IOCP.Error.timeout
            if case .timeout = error {
                // Expected
            } else {
                Issue.record("Expected .timeout case")
            }
        }
    }

    // MARK: - Conformance Tests

    extension Kernel.IOCP.Error.Test.Unit {
        @Test("Error conforms to Swift.Error")
        func isSwiftError() {
            let error: any Swift.Error = Kernel.IOCP.Error.timeout
            #expect(error is Kernel.IOCP.Error)
        }

        @Test("Error is Sendable")
        func isSendable() {
            let value: any Sendable = Kernel.IOCP.Error.timeout
            #expect(value is Kernel.IOCP.Error)
        }

        @Test("Error is Equatable")
        func isEquatable() {
            let a = Kernel.IOCP.Error.timeout
            let b = Kernel.IOCP.Error.timeout
            let c = Kernel.IOCP.Error.create(.win32(1))
            #expect(a == b)
            #expect(a != c)
        }

        @Test("Error is Hashable")
        func isHashable() {
            var set = Set<Kernel.IOCP.Error>()
            set.insert(.timeout)
            set.insert(.create(.win32(1)))
            set.insert(.timeout)  // duplicate
            #expect(set.count == 2)
        }
    }

    // MARK: - Description Tests

    extension Kernel.IOCP.Error.Test.Unit {
        @Test("create description contains CreateIoCompletionPort")
        func createDescription() {
            let error = Kernel.IOCP.Error.create(.win32(5))
            #expect(error.description.contains("CreateIoCompletionPort"))
        }

        @Test("associate description contains associate")
        func associateDescription() {
            let error = Kernel.IOCP.Error.associate(.win32(5))
            #expect(error.description.contains("associate"))
        }

        @Test("dequeue description contains GetQueuedCompletionStatus")
        func dequeueDescription() {
            let error = Kernel.IOCP.Error.dequeue(.win32(5))
            #expect(error.description.contains("GetQueuedCompletionStatus"))
        }

        @Test("post description contains PostQueuedCompletionStatus")
        func postDescription() {
            let error = Kernel.IOCP.Error.post(.win32(5))
            #expect(error.description.contains("PostQueuedCompletionStatus"))
        }

        @Test("read description contains ReadFile")
        func readDescription() {
            let error = Kernel.IOCP.Error.read(.win32(5))
            #expect(error.description.contains("ReadFile"))
        }

        @Test("write description contains WriteFile")
        func writeDescription() {
            let error = Kernel.IOCP.Error.write(.win32(5))
            #expect(error.description.contains("WriteFile"))
        }

        @Test("result description contains GetOverlappedResult")
        func resultDescription() {
            let error = Kernel.IOCP.Error.result(.win32(5))
            #expect(error.description.contains("GetOverlappedResult"))
        }

        @Test("timeout description contains timed out")
        func timeoutDescription() {
            let error = Kernel.IOCP.Error.timeout
            #expect(error.description.contains("timed out"))
        }
    }

    // MARK: - last() Helper Tests

    extension Kernel.IOCP.Error.Test.Unit {
        @Test("last returns UInt32")
        func lastReturnsUInt32() {
            let lastError = Kernel.IOCP.Error.last()
            #expect(lastError is UInt32)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IOCP.Error.Test.EdgeCase {
        @Test("All cases with same code are equal")
        func sameCaseSameCodeEqual() {
            let code = Kernel.Error.Code.win32(42)
            #expect(Kernel.IOCP.Error.create(code) == Kernel.IOCP.Error.create(code))
            #expect(Kernel.IOCP.Error.read(code) == Kernel.IOCP.Error.read(code))
        }

        @Test("Different cases with same code are not equal")
        func differentCasesSameCodeNotEqual() {
            let code = Kernel.Error.Code.win32(42)
            #expect(Kernel.IOCP.Error.create(code) != Kernel.IOCP.Error.read(code))
            #expect(Kernel.IOCP.Error.write(code) != Kernel.IOCP.Error.result(code))
        }
    }

#endif
