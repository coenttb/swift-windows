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

    extension Kernel.IO.Completion.Port {
        #TestSuites
    }

    // MARK: - API Unit Tests

    extension Kernel.IO.Completion.Port.Test.Unit {
        @Test("Port namespace exists")
        func namespaceExists() {
            _ = Kernel.IO.Completion.Port.self
        }

        @Test("create returns valid descriptor")
        func createReturnsValidDescriptor() throws {
            let port = try Kernel.IO.Completion.Port.create()
            defer { Kernel.IO.Completion.Port.close(port) }

            #expect(port.rawValue != INVALID_HANDLE_VALUE)
        }

        @Test("create with concurrency parameter")
        func createWithConcurrency() throws {
            // Create port with specific thread count
            let port = try Kernel.IO.Completion.Port.create(threads: 4)
            defer { Kernel.IO.Completion.Port.close(port) }

            #expect(port.rawValue != INVALID_HANDLE_VALUE)
        }

        @Test("create multiple ports are independent")
        func createMultiplePorts() throws {
            let port1 = try Kernel.IO.Completion.Port.create()
            defer { Kernel.IO.Completion.Port.close(port1) }

            let port2 = try Kernel.IO.Completion.Port.create()
            defer { Kernel.IO.Completion.Port.close(port2) }

            #expect(port1.rawValue != port2.rawValue)
        }

        @Test("close completes without error")
        func closeCompletesWithoutError() throws {
            let port = try Kernel.IO.Completion.Port.create()
            Kernel.IO.Completion.Port.close(port)
            // No throw means success
        }
    }

    // MARK: - Post and Dequeue Tests

    extension Kernel.IO.Completion.Port.Test.Unit {
        @Test("post completion to port")
        func postCompletion() throws {
            let port = try Kernel.IO.Completion.Port.create()
            defer { Kernel.IO.Completion.Port.close(port) }

            // Post a completion packet
            try Kernel.IO.Completion.Port.post(
                port,
                bytes: 42,
                key: Kernel.IO.Completion.Port.Key(123)
            )
        }

        @Test("post and dequeue single completion")
        func postAndDequeueSingle() throws {
            let port = try Kernel.IO.Completion.Port.create()
            defer { Kernel.IO.Completion.Port.close(port) }

            let expected: DWORD = 100
            let expectedKey = Kernel.IO.Completion.Port.Key(456)

            // Post a completion
            try Kernel.IO.Completion.Port.post(
                port,
                bytes: expected,
                key: expectedKey
            )

            // Dequeue it
            let result = try Kernel.IO.Completion.Port.Dequeue.single(port, timeout: 1000)

            #expect(result.bytes == expected)
            #expect(result.key == expectedKey)
            #expect(result.overlapped == nil)
        }

        @Test("post multiple completions and dequeue in order")
        func postMultipleAndDequeue() throws {
            let port = try Kernel.IO.Completion.Port.create()
            defer { Kernel.IO.Completion.Port.close(port) }

            // Post multiple completions
            for i: DWORD in 0..<5 {
                try Kernel.IO.Completion.Port.post(
                    port,
                    bytes: i * 10,
                    key: Kernel.IO.Completion.Port.Key(ULONG_PTR(i))
                )
            }

            // Dequeue all (FIFO order)
            for i: DWORD in 0..<5 {
                let result = try Kernel.IO.Completion.Port.Dequeue.single(port, timeout: 1000)
                #expect(result.bytes == i * 10)
                #expect(result.key.rawValue == ULONG_PTR(i))
            }
        }

        @Test("dequeue times out when no completions")
        func dequeueTimesOut() throws {
            let port = try Kernel.IO.Completion.Port.create()
            defer { Kernel.IO.Completion.Port.close(port) }

            // Try to dequeue with a short timeout (should timeout)
            #expect(throws: Kernel.IO.Completion.Port.Error.self) {
                _ = try Kernel.IO.Completion.Port.Dequeue.single(port, timeout: 10)
            }
        }

        @Test("dequeue timeout throws correct error")
        func dequeueTimeoutCorrectError() throws {
            let port = try Kernel.IO.Completion.Port.create()
            defer { Kernel.IO.Completion.Port.close(port) }

            do {
                _ = try Kernel.IO.Completion.Port.Dequeue.single(port, timeout: 10)
                Issue.record("Expected timeout error")
            } catch {
                if case .timeout = error {
                    // Expected
                } else {
                    Issue.record("Expected .timeout, got \(error)")
                }
            }
        }
    }

    // MARK: - Batch Dequeue Tests

    extension Kernel.IO.Completion.Port.Test.Unit {
        @Test("batch dequeue returns zero on timeout")
        func batchDequeueTimesOut() throws {
            let port = try Kernel.IO.Completion.Port.create()
            defer { Kernel.IO.Completion.Port.close(port) }

            var entries = [OVERLAPPED_ENTRY](repeating: OVERLAPPED_ENTRY(), count: 10)
            let count = try entries.withUnsafeMutableBufferPointer { buffer in
                try Kernel.IO.Completion.Port.Dequeue.batch(port, entries: buffer, timeout: 10)
            }

            #expect(count == 0)
        }

        @Test("batch dequeue retrieves multiple completions")
        func batchDequeueMultiple() throws {
            let port = try Kernel.IO.Completion.Port.create()
            defer { Kernel.IO.Completion.Port.close(port) }

            let postCount = 5

            // Post multiple completions
            for i in 0..<postCount {
                try Kernel.IO.Completion.Port.post(
                    port,
                    bytes: DWORD(i * 10),
                    key: Kernel.IO.Completion.Port.Key(ULONG_PTR(i))
                )
            }

            // Batch dequeue
            var entries = [OVERLAPPED_ENTRY](repeating: OVERLAPPED_ENTRY(), count: 10)
            let count = try entries.withUnsafeMutableBufferPointer { buffer in
                try Kernel.IO.Completion.Port.Dequeue.batch(port, entries: buffer, timeout: 1000)
            }

            #expect(count == postCount)

            // Verify entries
            for i in 0..<count {
                #expect(entries[i].dwNumberOfBytesTransferred == DWORD(i * 10))
                #expect(entries[i].lpCompletionKey == ULONG_PTR(i))
            }
        }

        @Test("batch dequeue with smaller buffer than completions")
        func batchDequeuePartial() throws {
            let port = try Kernel.IO.Completion.Port.create()
            defer { Kernel.IO.Completion.Port.close(port) }

            // Post 10 completions
            for i in 0..<10 {
                try Kernel.IO.Completion.Port.post(
                    port,
                    bytes: DWORD(i),
                    key: Kernel.IO.Completion.Port.Key(ULONG_PTR(i))
                )
            }

            // Batch dequeue with buffer of 3
            var entries = [OVERLAPPED_ENTRY](repeating: OVERLAPPED_ENTRY(), count: 3)
            let count = try entries.withUnsafeMutableBufferPointer { buffer in
                try Kernel.IO.Completion.Port.Dequeue.batch(port, entries: buffer, timeout: 1000)
            }

            #expect(count <= 3)
            #expect(count >= 1)
        }
    }

    // MARK: - Nested Types Tests

    extension Kernel.IO.Completion.Port.Test.Unit {
        @Test("Error type exists")
        func errorTypeExists() {
            let _: Kernel.IO.Completion.Port.Error.Type = Kernel.IO.Completion.Port.Error.self
        }

        @Test("Entry type exists")
        func entryTypeExists() {
            let _: Kernel.IO.Completion.Port.Entry.Type = Kernel.IO.Completion.Port.Entry.self
        }

        @Test("Overlapped type exists")
        func overlappedTypeExists() {
            let _: Kernel.IO.Completion.Port.Overlapped.Type = Kernel.IO.Completion.Port.Overlapped.self
        }

        @Test("Dequeue type exists")
        func dequeueTypeExists() {
            let _: Kernel.IO.Completion.Port.Dequeue.Type = Kernel.IO.Completion.Port.Dequeue.self
        }

        @Test("Cancel type exists")
        func cancelTypeExists() {
            let _: Kernel.IO.Completion.Port.Cancel.Type = Kernel.IO.Completion.Port.Cancel.self
        }

        @Test("Key type exists")
        func keyTypeExists() {
            let _: Kernel.IO.Completion.Port.Key.Type = Kernel.IO.Completion.Port.Key.self
        }

        @Test("Read.Result type exists")
        func readResultTypeExists() {
            let _: Kernel.IO.Completion.Port.Read.Result.Type = Kernel.IO.Completion.Port.Read.Result.self
        }

        @Test("Write.Result type exists")
        func writeResultTypeExists() {
            let _: Kernel.IO.Completion.Port.Write.Result.Type = Kernel.IO.Completion.Port.Write.Result.self
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IO.Completion.Port.Test.EdgeCase {
        @Test("post with zero bytes")
        func postZeroBytes() throws {
            let port = try Kernel.IO.Completion.Port.create()
            defer { Kernel.IO.Completion.Port.close(port) }

            try Kernel.IO.Completion.Port.post(port, bytes: 0)

            let result = try Kernel.IO.Completion.Port.Dequeue.single(port, timeout: 1000)
            #expect(result.bytes == 0)
        }

        @Test("post with maximum key value")
        func postMaxKey() throws {
            let port = try Kernel.IO.Completion.Port.create()
            defer { Kernel.IO.Completion.Port.close(port) }

            let maxKey = Kernel.IO.Completion.Port.Key(rawValue: ULONG_PTR.max)
            try Kernel.IO.Completion.Port.post(port, key: maxKey)

            let result = try Kernel.IO.Completion.Port.Dequeue.single(port, timeout: 1000)
            #expect(result.key == maxKey)
        }

        @Test("create and immediately close")
        func createAndImmediatelyClose() throws {
            for _ in 0..<100 {
                let port = try Kernel.IO.Completion.Port.create()
                Kernel.IO.Completion.Port.close(port)
            }
        }
    }

#endif
