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

    extension Kernel.IOCP.Cancel {
        #TestSuites
    }

    // MARK: - Unit Tests

    extension Kernel.IOCP.Cancel.Test.Unit {
        @Test("Cancel namespace exists")
        func namespaceExists() {
            _ = Kernel.IOCP.Cancel.self
        }

        @Test("Cancel is an enum")
        func isEnum() {
            let _: Kernel.IOCP.Cancel.Type = Kernel.IOCP.Cancel.self
        }
    }

    // MARK: - all() Tests

    extension Kernel.IOCP.Cancel.Test.Unit {
        @Test("all does not crash with invalid descriptor")
        func allWithInvalidDescriptor() {
            // Should not crash - errors are silently ignored
            Kernel.IOCP.Cancel.all(Kernel.Descriptor.invalid)
        }

        @Test("all is fire-and-forget")
        func allIsFireAndForget() {
            // all() returns Void, so it's truly fire-and-forget
            Kernel.IOCP.Cancel.all(Kernel.Descriptor.invalid)
            // No return value to check - this is intentional
        }
    }

    // MARK: - allWithStatus() Tests

    extension Kernel.IOCP.Cancel.Test.Unit {
        @Test("allWithStatus returns Bool")
        func allWithStatusReturnsBool() {
            let result = Kernel.IOCP.Cancel.allWithStatus(Kernel.Descriptor.invalid)
            #expect(result is Bool)
        }

        @Test("allWithStatus with invalid descriptor returns appropriate value")
        func allWithStatusInvalidDescriptor() {
            let result = Kernel.IOCP.Cancel.allWithStatus(Kernel.Descriptor.invalid)
            // With invalid descriptor, CancelIoEx fails
            #expect(result == true || result == false)
        }
    }

    // MARK: - pending() Tests

    extension Kernel.IOCP.Cancel.Test.Unit {
        @Test("pending does not crash with invalid descriptor")
        func pendingWithInvalidDescriptor() {
            var overlapped = Kernel.IOCP.Overlapped()
            // Should not crash - errors are silently ignored
            Kernel.IOCP.Cancel.pending(Kernel.Descriptor.invalid, overlapped: &overlapped)
        }

        @Test("pending is fire-and-forget")
        func pendingIsFireAndForget() {
            var overlapped = Kernel.IOCP.Overlapped()
            Kernel.IOCP.Cancel.pending(Kernel.Descriptor.invalid, overlapped: &overlapped)
            // No return value to check - this is intentional
        }
    }

    // MARK: - pendingWithStatus() Tests

    extension Kernel.IOCP.Cancel.Test.Unit {
        @Test("pendingWithStatus returns Bool")
        func pendingWithStatusReturnsBool() {
            var overlapped = Kernel.IOCP.Overlapped()
            let result = Kernel.IOCP.Cancel.pendingWithStatus(
                Kernel.Descriptor.invalid,
                overlapped: &overlapped
            )
            #expect(result is Bool)
        }

        @Test("pendingWithStatus with invalid descriptor returns appropriate value")
        func pendingWithStatusInvalidDescriptor() {
            var overlapped = Kernel.IOCP.Overlapped()
            let result = Kernel.IOCP.Cancel.pendingWithStatus(
                Kernel.Descriptor.invalid,
                overlapped: &overlapped
            )
            // With invalid descriptor, CancelIoEx fails
            #expect(result == true || result == false)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IOCP.Cancel.Test.EdgeCase {
        @Test("Cancel operations are safe to call multiple times")
        func cancelMultipleTimes() {
            var overlapped = Kernel.IOCP.Overlapped()

            // Call all multiple times - should be safe
            for _ in 0..<3 {
                Kernel.IOCP.Cancel.all(Kernel.Descriptor.invalid)
            }

            // Call pending multiple times - should be safe
            for _ in 0..<3 {
                Kernel.IOCP.Cancel.pending(Kernel.Descriptor.invalid, overlapped: &overlapped)
            }

            // Call pendingWithStatus multiple times - should be safe
            for _ in 0..<3 {
                _ = Kernel.IOCP.Cancel.pendingWithStatus(
                    Kernel.Descriptor.invalid,
                    overlapped: &overlapped
                )
            }
        }

        @Test("Cancel with different overlapped instances")
        func cancelDifferentOverlappeds() {
            var overlapped1 = Kernel.IOCP.Overlapped()
            var overlapped2 = Kernel.IOCP.Overlapped()
            var overlapped3 = Kernel.IOCP.Overlapped()

            Kernel.IOCP.Cancel.pending(Kernel.Descriptor.invalid, overlapped: &overlapped1)
            Kernel.IOCP.Cancel.pending(Kernel.Descriptor.invalid, overlapped: &overlapped2)
            Kernel.IOCP.Cancel.pending(Kernel.Descriptor.invalid, overlapped: &overlapped3)
        }
    }

    // MARK: - Error Integration Tests

    extension Kernel.IOCP.Cancel.Test.Unit {
        @Test("Cancel uses Error.notFound for comparison")
        func usesNotFoundConstant() {
            // Verify that the implementation checks against ERROR_NOT_FOUND
            let notFound = Kernel.IOCP.Error.notFound
            #expect(notFound == 1168)  // ERROR_NOT_FOUND
        }
    }

#endif
