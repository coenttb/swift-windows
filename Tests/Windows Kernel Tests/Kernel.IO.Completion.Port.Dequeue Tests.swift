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

        @Test("Status type exists with ok and platform cases")
        func statusType() {
            let ok: Kernel.IO.Completion.Port.Dequeue.Status = .ok
            let error: Kernel.IO.Completion.Port.Dequeue.Status = .platform(.win32(0))

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
            #expect(item.overlapped != nil)
            #expect(item.overlapped == ov)
            #expect(item.status == .ok)
        }

        @Test("Item can have nil overlapped")
        func itemNilOverlapped() {
            let item = Kernel.IO.Completion.Port.Dequeue.Item(
                bytes: 0,
                key: .init(rawValue: 0),
                overlapped: nil,
                status: .ok
            )

            #expect(item.overlapped == nil)
            #expect(item.status == .ok)
        }

        @Test("Item with platform error status")
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
                status: .platform(.win32(5))
            )

            if case .platform(let code) = item.status {
                #expect(code == .win32(5))
            } else {
                #expect(Bool(false), "Expected platform error status")
            }
        }

        @Test("single throws .timeout on timeout")
        func singleTimeout() throws {
            let port = try Kernel.IO.Completion.Port.create()
            defer { Kernel.IO.Completion.Port.close(port) }

            do {
                _ = try Kernel.IO.Completion.Port.Dequeue.single(port, timeout: 0)
                #expect(Bool(false), "Expected .timeout")
            } catch let e as Kernel.IO.Completion.Port.Error {
                #expect(e == .timeout)
            }
        }

        @Test("single returns .ok for posted completion with overlapped")
        func singlePostedCompletionWithOverlapped() throws {
            let port = try Kernel.IO.Completion.Port.create()
            defer { Kernel.IO.Completion.Port.close(port) }

            let ov = UnsafeMutablePointer<OVERLAPPED>.allocate(capacity: 1)
            ov.initialize(to: OVERLAPPED())
            defer {
                ov.deinitialize(count: 1)
                ov.deallocate()
            }

            try Kernel.IO.Completion.Port.post(port, bytes: 7, key: .init(rawValue: 1), overlapped: ov)

            let item = try Kernel.IO.Completion.Port.Dequeue.single(port, timeout: 1_000)
            #expect(item.bytes == 7)
            #expect(item.key == .init(rawValue: 1))
            #expect(item.overlapped == ov)
            #expect(item.status == .ok)
        }

        @Test("single returns .ok for posted completion without overlapped")
        func singlePostedCompletionWithoutOverlapped() throws {
            let port = try Kernel.IO.Completion.Port.create()
            defer { Kernel.IO.Completion.Port.close(port) }

            try Kernel.IO.Completion.Port.post(port, bytes: 42, key: .init(rawValue: 123))

            let item = try Kernel.IO.Completion.Port.Dequeue.single(port, timeout: 1_000)
            #expect(item.bytes == 42)
            #expect(item.key == .init(rawValue: 123))
            #expect(item.overlapped == nil)
            #expect(item.status == .ok)
        }
    }

#endif
