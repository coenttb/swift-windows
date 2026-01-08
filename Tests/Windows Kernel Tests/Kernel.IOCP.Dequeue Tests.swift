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

    extension Kernel.IOCP.Dequeue {
        #TestSuites
    }

    // MARK: - Unit Tests

    extension Kernel.IOCP.Dequeue.Test.Unit {
        @Test("Dequeue namespace exists")
        func namespaceExists() {
            _ = Kernel.IOCP.Dequeue.self
        }

        @Test("Dequeue is an enum")
        func isEnum() {
            let _: Kernel.IOCP.Dequeue.Type = Kernel.IOCP.Dequeue.self
        }
    }

    // MARK: - single() Tests

    extension Kernel.IOCP.Dequeue.Test.Unit {
        @Test("single returns posted completion")
        func singleReturnsPostedCompletion() throws {
            let port = try Kernel.IOCP.create()
            defer { Kernel.IOCP.close(port) }

            let expectedBytes: DWORD = 42
            let expectedKey = Kernel.IOCP.Completion.Key(123)

            try Kernel.IOCP.post(port, bytesTransferred: expectedBytes, key: expectedKey)

            let result = try Kernel.IOCP.Dequeue.single(port, timeout: 1000)

            #expect(result.bytesTransferred == expectedBytes)
            #expect(result.key == expectedKey)
            #expect(result.overlapped == nil)
        }

        @Test("single throws timeout on empty port")
        func singleThrowsTimeoutOnEmpty() throws {
            let port = try Kernel.IOCP.create()
            defer { Kernel.IOCP.close(port) }

            do {
                _ = try Kernel.IOCP.Dequeue.single(port, timeout: 10)
                Issue.record("Expected timeout error")
            } catch {
                if case .timeout = error {
                    // Expected
                } else {
                    Issue.record("Expected .timeout, got \(error)")
                }
            }
        }

        @Test("single respects FIFO ordering")
        func singleRespectsFIFO() throws {
            let port = try Kernel.IOCP.create()
            defer { Kernel.IOCP.close(port) }

            // Post in specific order
            for i: DWORD in 1...5 {
                try Kernel.IOCP.post(port, bytesTransferred: i * 100, key: Kernel.IOCP.Completion.Key(ULONG_PTR(i)))
            }

            // Dequeue and verify FIFO order
            for i: DWORD in 1...5 {
                let result = try Kernel.IOCP.Dequeue.single(port, timeout: 1000)
                #expect(result.bytesTransferred == i * 100)
                #expect(result.key.rawValue == ULONG_PTR(i))
            }
        }

        @Test("single timeout parameter is respected")
        func singleTimeoutRespected() throws {
            let port = try Kernel.IOCP.create()
            defer { Kernel.IOCP.close(port) }

            // Measure that short timeout actually times out quickly
            let start = GetTickCount64()
            do {
                _ = try Kernel.IOCP.Dequeue.single(port, timeout: 50)
                Issue.record("Expected timeout")
            } catch {
                let elapsed = GetTickCount64() - start
                // Should timeout in roughly 50ms (allow some slack)
                #expect(elapsed >= 40)
                #expect(elapsed < 200)
            }
        }
    }

    // MARK: - batch() Tests

    extension Kernel.IOCP.Dequeue.Test.Unit {
        @Test("batch returns zero on timeout")
        func batchReturnsZeroOnTimeout() throws {
            let port = try Kernel.IOCP.create()
            defer { Kernel.IOCP.close(port) }

            var entries = [OVERLAPPED_ENTRY](repeating: OVERLAPPED_ENTRY(), count: 10)
            let count = try entries.withUnsafeMutableBufferPointer { buffer in
                try Kernel.IOCP.Dequeue.batch(port, entries: buffer, timeout: 10)
            }

            #expect(count == 0)
        }

        @Test("batch returns all available completions")
        func batchReturnsAllCompletions() throws {
            let port = try Kernel.IOCP.create()
            defer { Kernel.IOCP.close(port) }

            let postCount = 5

            // Post multiple completions
            for i in 0..<postCount {
                try Kernel.IOCP.post(
                    port,
                    bytesTransferred: DWORD(i * 10),
                    key: Kernel.IOCP.Completion.Key(ULONG_PTR(i))
                )
            }

            // Batch dequeue
            var entries = [OVERLAPPED_ENTRY](repeating: OVERLAPPED_ENTRY(), count: 10)
            let count = try entries.withUnsafeMutableBufferPointer { buffer in
                try Kernel.IOCP.Dequeue.batch(port, entries: buffer, timeout: 1000)
            }

            #expect(count == postCount)

            // Verify entries in FIFO order
            for i in 0..<count {
                #expect(entries[i].dwNumberOfBytesTransferred == DWORD(i * 10))
                #expect(entries[i].lpCompletionKey == ULONG_PTR(i))
            }
        }

        @Test("batch respects buffer size limit")
        func batchRespectsBufferLimit() throws {
            let port = try Kernel.IOCP.create()
            defer { Kernel.IOCP.close(port) }

            // Post 10 completions
            for i in 0..<10 {
                try Kernel.IOCP.post(
                    port,
                    bytesTransferred: DWORD(i),
                    key: Kernel.IOCP.Completion.Key(ULONG_PTR(i))
                )
            }

            // Dequeue with buffer of 3
            var entries = [OVERLAPPED_ENTRY](repeating: OVERLAPPED_ENTRY(), count: 3)
            let count = try entries.withUnsafeMutableBufferPointer { buffer in
                try Kernel.IOCP.Dequeue.batch(port, entries: buffer, timeout: 1000)
            }

            #expect(count >= 1)
            #expect(count <= 3)
        }

        @Test("batch returns zero for nil buffer")
        func batchReturnsZeroForNilBuffer() throws {
            let port = try Kernel.IOCP.create()
            defer { Kernel.IOCP.close(port) }

            // Empty buffer pointer
            let buffer = UnsafeMutableBufferPointer<OVERLAPPED_ENTRY>(start: nil, count: 0)
            let count = try Kernel.IOCP.Dequeue.batch(port, entries: buffer, timeout: 10)

            #expect(count == 0)
        }

        @Test("batch can drain queue over multiple calls")
        func batchDrainsQueueOverMultipleCalls() throws {
            let port = try Kernel.IOCP.create()
            defer { Kernel.IOCP.close(port) }

            // Post 10 completions
            for i in 0..<10 {
                try Kernel.IOCP.post(port, key: Kernel.IOCP.Completion.Key(ULONG_PTR(i)))
            }

            var totalDequeued = 0
            var entries = [OVERLAPPED_ENTRY](repeating: OVERLAPPED_ENTRY(), count: 3)

            // Keep dequeueing until timeout
            while true {
                let count = try entries.withUnsafeMutableBufferPointer { buffer in
                    try Kernel.IOCP.Dequeue.batch(port, entries: buffer, timeout: 50)
                }
                if count == 0 { break }
                totalDequeued += count
            }

            #expect(totalDequeued == 10)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IOCP.Dequeue.Test.EdgeCase {
        @Test("single with zero timeout returns immediately")
        func singleZeroTimeout() throws {
            let port = try Kernel.IOCP.create()
            defer { Kernel.IOCP.close(port) }

            // Post one completion
            try Kernel.IOCP.post(port, bytesTransferred: 1)

            // Zero timeout should still return the available completion
            let result = try Kernel.IOCP.Dequeue.single(port, timeout: 0)
            #expect(result.bytesTransferred == 1)

            // Next call should throw timeout
            #expect(throws: Kernel.IOCP.Error.self) {
                _ = try Kernel.IOCP.Dequeue.single(port, timeout: 0)
            }
        }

        @Test("batch with zero timeout returns available completions")
        func batchZeroTimeout() throws {
            let port = try Kernel.IOCP.create()
            defer { Kernel.IOCP.close(port) }

            // Post some completions
            for i in 0..<3 {
                try Kernel.IOCP.post(port, key: Kernel.IOCP.Completion.Key(ULONG_PTR(i)))
            }

            var entries = [OVERLAPPED_ENTRY](repeating: OVERLAPPED_ENTRY(), count: 10)
            let count = try entries.withUnsafeMutableBufferPointer { buffer in
                try Kernel.IOCP.Dequeue.batch(port, entries: buffer, timeout: 0)
            }

            #expect(count >= 1)
        }

        @Test("single preserves maximum key value")
        func singleMaxKey() throws {
            let port = try Kernel.IOCP.create()
            defer { Kernel.IOCP.close(port) }

            let maxKey = Kernel.IOCP.Completion.Key(rawValue: ULONG_PTR.max)
            try Kernel.IOCP.post(port, key: maxKey)

            let result = try Kernel.IOCP.Dequeue.single(port, timeout: 1000)
            #expect(result.key == maxKey)
        }

        @Test("single preserves maximum bytes value")
        func singleMaxBytes() throws {
            let port = try Kernel.IOCP.create()
            defer { Kernel.IOCP.close(port) }

            let maxBytes = DWORD.max
            try Kernel.IOCP.post(port, bytesTransferred: maxBytes)

            let result = try Kernel.IOCP.Dequeue.single(port, timeout: 1000)
            #expect(result.bytesTransferred == maxBytes)
        }
    }

#endif
