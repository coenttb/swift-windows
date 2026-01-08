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

        @Test("Status type exists with ok and operationError cases")
        func statusType() {
            let ok: Kernel.IO.Completion.Port.Dequeue.Status = .ok
            let error: Kernel.IO.Completion.Port.Dequeue.Status = .operationError(.win32(0))

            #expect(ok == .ok)
            #expect(error != .ok)
        }

        @Test("Item type exists with expected properties")
        func itemType() {
            let ov = UnsafeMutablePointer<OVERLAPPED>.allocate(capacity: 1)
            ov.initialize(to: OVERLAPPED())
            defer {
                ov.deinitialize(count: 1)
                ov.deallocate()
            }

            let item = Kernel.IO.Completion.Port.Dequeue.Item(
                bytes: 42,
                key: .init(rawValue: 0xBEEF),
                overlapped: ov,
                status: .ok
            )

            #expect(item.bytes == 42)
            #expect(item.key == .init(rawValue: 0xBEEF))
            #expect(item.overlapped == ov)
            #expect(item.status == .ok)
        }

        @Test("Item with operationError status")
        func itemWithError() {
            let ov = UnsafeMutablePointer<OVERLAPPED>.allocate(capacity: 1)
            ov.initialize(to: OVERLAPPED())
            defer {
                ov.deinitialize(count: 1)
                ov.deallocate()
            }

            let item = Kernel.IO.Completion.Port.Dequeue.Item(
                bytes: 0,
                key: .init(rawValue: 0),
                overlapped: ov,
                status: .operationError(.win32(5))
            )

            if case .operationError(let code) = item.status {
                #expect(code == .win32(5))
            } else {
                #expect(Bool(false), "Expected operationError status")
            }
        }
    }

#endif
