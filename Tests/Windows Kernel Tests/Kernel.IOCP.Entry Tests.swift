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

    extension Kernel.IOCP.Entry {
        #TestSuites
    }

    // MARK: - Unit Tests

    extension Kernel.IOCP.Entry.Test.Unit {
        @Test("Entry type exists")
        func typeExists() {
            let _: Kernel.IOCP.Entry.Type = Kernel.IOCP.Entry.self
        }

        @Test("Entry default init creates zero-initialized entry")
        func defaultInit() {
            let entry = Kernel.IOCP.Entry()
            #expect(entry.key.rawValue == 0)
            #expect(entry.bytes.transferred == .zero)
        }
    }

    // MARK: - Accessors Tests

    extension Kernel.IOCP.Entry.Test.Unit {
        @Test("key accessor returns completion key")
        func keyAccessor() throws {
            let port = try Kernel.IOCP.create()
            defer { Kernel.IOCP.close(port) }

            let expectedKey = Kernel.IOCP.Completion.Key(0xDEAD_BEEF)
            try Kernel.IOCP.post(port, key: expectedKey)

            var entries = [OVERLAPPED_ENTRY](repeating: OVERLAPPED_ENTRY(), count: 1)
            let count = try entries.withUnsafeMutableBufferPointer { buffer in
                try Kernel.IOCP.Dequeue.batch(port, entries: buffer, timeout: 1000)
            }

            #expect(count == 1)

            // Access via Entry wrapper
            var entry = Kernel.IOCP.Entry()
            entry.raw = entries[0]
            #expect(entry.key == expectedKey)
        }

        @Test("bytes.transferred accessor returns bytes")
        func bytesTransferredAccessor() throws {
            let port = try Kernel.IOCP.create()
            defer { Kernel.IOCP.close(port) }

            let expectedBytes: DWORD = 1024
            try Kernel.IOCP.post(port, bytesTransferred: expectedBytes)

            var entries = [OVERLAPPED_ENTRY](repeating: OVERLAPPED_ENTRY(), count: 1)
            let count = try entries.withUnsafeMutableBufferPointer { buffer in
                try Kernel.IOCP.Dequeue.batch(port, entries: buffer, timeout: 1000)
            }

            #expect(count == 1)

            var entry = Kernel.IOCP.Entry()
            entry.raw = entries[0]
            #expect(entry.bytes.transferred == Kernel.File.Size(Int64(expectedBytes)))
        }

        @Test("Bytes struct is Sendable")
        func bytesIsSendable() {
            let entry = Kernel.IOCP.Entry()
            let bytes: any Sendable = entry.bytes
            #expect(bytes is Kernel.IOCP.Entry.Bytes)
        }
    }

    // MARK: - Conformance Tests

    extension Kernel.IOCP.Entry.Test.Unit {
        @Test("Entry is Sendable")
        func isSendable() {
            let entry: any Sendable = Kernel.IOCP.Entry()
            #expect(entry is Kernel.IOCP.Entry)
        }
    }

    // MARK: - Integration Tests

    extension Kernel.IOCP.Entry.Test.Unit {
        @Test("Entry values from batch dequeue match posted values")
        func entryFromBatchDequeue() throws {
            let port = try Kernel.IOCP.create()
            defer { Kernel.IOCP.close(port) }

            let testCases: [(bytes: DWORD, key: UInt)] = [
                (100, 1),
                (200, 2),
                (300, 3),
            ]

            for tc in testCases {
                try Kernel.IOCP.post(
                    port,
                    bytesTransferred: tc.bytes,
                    key: Kernel.IOCP.Completion.Key(tc.key)
                )
            }

            var rawEntries = [OVERLAPPED_ENTRY](repeating: OVERLAPPED_ENTRY(), count: 10)
            let count = try rawEntries.withUnsafeMutableBufferPointer { buffer in
                try Kernel.IOCP.Dequeue.batch(port, entries: buffer, timeout: 1000)
            }

            #expect(count == testCases.count)

            for (i, tc) in testCases.enumerated() {
                var entry = Kernel.IOCP.Entry()
                entry.raw = rawEntries[i]
                #expect(entry.bytes.transferred == Kernel.File.Size(Int64(tc.bytes)))
                #expect(entry.key.rawValue == ULONG_PTR(tc.key))
            }
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IOCP.Entry.Test.EdgeCase {
        @Test("Entry with zero bytes and zero key")
        func zeroValues() throws {
            let port = try Kernel.IOCP.create()
            defer { Kernel.IOCP.close(port) }

            try Kernel.IOCP.post(port, bytesTransferred: 0, key: .zero)

            var entries = [OVERLAPPED_ENTRY](repeating: OVERLAPPED_ENTRY(), count: 1)
            _ = try entries.withUnsafeMutableBufferPointer { buffer in
                try Kernel.IOCP.Dequeue.batch(port, entries: buffer, timeout: 1000)
            }

            var entry = Kernel.IOCP.Entry()
            entry.raw = entries[0]
            #expect(entry.bytes.transferred == .zero)
            #expect(entry.key.rawValue == 0)
        }

        @Test("Entry with maximum values")
        func maxValues() throws {
            let port = try Kernel.IOCP.create()
            defer { Kernel.IOCP.close(port) }

            let maxBytes = DWORD.max
            let maxKey = Kernel.IOCP.Completion.Key(rawValue: ULONG_PTR.max)

            try Kernel.IOCP.post(port, bytesTransferred: maxBytes, key: maxKey)

            var entries = [OVERLAPPED_ENTRY](repeating: OVERLAPPED_ENTRY(), count: 1)
            _ = try entries.withUnsafeMutableBufferPointer { buffer in
                try Kernel.IOCP.Dequeue.batch(port, entries: buffer, timeout: 1000)
            }

            var entry = Kernel.IOCP.Entry()
            entry.raw = entries[0]
            #expect(entry.bytes.transferred == Kernel.File.Size(Int64(maxBytes)))
            #expect(entry.key == maxKey)
        }

        @Test("Multiple entries maintain distinct values")
        func multipleDistinctEntries() throws {
            let port = try Kernel.IOCP.create()
            defer { Kernel.IOCP.close(port) }

            // Post with distinct patterns
            for i: UInt in 0..<5 {
                try Kernel.IOCP.post(
                    port,
                    bytesTransferred: DWORD(i * 111),
                    key: Kernel.IOCP.Completion.Key(i * 222)
                )
            }

            var entries = [OVERLAPPED_ENTRY](repeating: OVERLAPPED_ENTRY(), count: 5)
            let count = try entries.withUnsafeMutableBufferPointer { buffer in
                try Kernel.IOCP.Dequeue.batch(port, entries: buffer, timeout: 1000)
            }

            #expect(count == 5)

            for i in 0..<count {
                var entry = Kernel.IOCP.Entry()
                entry.raw = entries[i]
                #expect(entry.bytes.transferred == Kernel.File.Size(Int64(i * 111)))
                #expect(entry.key.rawValue == ULONG_PTR(i * 222))
            }
        }
    }

#endif
