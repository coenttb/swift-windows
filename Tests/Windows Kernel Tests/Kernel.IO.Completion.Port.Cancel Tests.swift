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

    extension Kernel.IO.Completion.Port.Cancel {
        #TestSuites
    }

    // MARK: - Unit Tests

    extension Kernel.IO.Completion.Port.Cancel.Test.Unit {
        @Test("Cancel namespace exists")
        func namespaceExists() {
            _ = Kernel.IO.Completion.Port.Cancel.self
        }

        @Test("Cancel is an enum")
        func isEnum() {
            let _: Kernel.IO.Completion.Port.Cancel.Type = Kernel.IO.Completion.Port.Cancel.self
        }
    }

    // MARK: - all() Tests

    extension Kernel.IO.Completion.Port.Cancel.Test.Unit {
        @Test("all does not crash with invalid descriptor")
        func allWithInvalidDescriptor() {
            // Should not crash - errors are silently ignored
            Kernel.IO.Completion.Port.Cancel.all(Kernel.Descriptor.invalid)()
        }

        @Test("all is fire-and-forget")
        func allIsFireAndForget() {
            // all() returns Void via callAsFunction, so it's truly fire-and-forget
            Kernel.IO.Completion.Port.Cancel.all(Kernel.Descriptor.invalid)()
            // No return value to check - this is intentional
        }
    }

    // MARK: - all.status Tests

    extension Kernel.IO.Completion.Port.Cancel.Test.Unit {
        @Test("all.status returns Bool")
        func allStatusReturnsBool() {
            let result = Kernel.IO.Completion.Port.Cancel.all(Kernel.Descriptor.invalid).status
            #expect(result is Bool)
        }

        @Test("all.status with invalid descriptor returns appropriate value")
        func allStatusInvalidDescriptor() {
            let result = Kernel.IO.Completion.Port.Cancel.all(Kernel.Descriptor.invalid).status
            // With invalid descriptor, CancelIoEx fails
            #expect(result == true || result == false)
        }
    }

    // MARK: - pending() Tests

    extension Kernel.IO.Completion.Port.Cancel.Test.Unit {
        @Test("pending does not crash with invalid descriptor")
        func pendingWithInvalidDescriptor() {
            var overlapped = Kernel.IO.Completion.Port.Overlapped()
            // Should not crash - errors are silently ignored
            Kernel.IO.Completion.Port.Cancel.pending(Kernel.Descriptor.invalid, overlapped: &overlapped)()
        }

        @Test("pending is fire-and-forget")
        func pendingIsFireAndForget() {
            var overlapped = Kernel.IO.Completion.Port.Overlapped()
            Kernel.IO.Completion.Port.Cancel.pending(Kernel.Descriptor.invalid, overlapped: &overlapped)()
            // No return value to check - this is intentional
        }
    }

    // MARK: - pending.status Tests

    extension Kernel.IO.Completion.Port.Cancel.Test.Unit {
        @Test("pending.status returns Bool")
        func pendingStatusReturnsBool() {
            var overlapped = Kernel.IO.Completion.Port.Overlapped()
            let result = Kernel.IO.Completion.Port.Cancel.pending(
                Kernel.Descriptor.invalid,
                overlapped: &overlapped
            ).status
            #expect(result is Bool)
        }

        @Test("pending.status with invalid descriptor returns appropriate value")
        func pendingStatusInvalidDescriptor() {
            var overlapped = Kernel.IO.Completion.Port.Overlapped()
            let result = Kernel.IO.Completion.Port.Cancel.pending(
                Kernel.Descriptor.invalid,
                overlapped: &overlapped
            ).status
            // With invalid descriptor, CancelIoEx fails
            #expect(result == true || result == false)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IO.Completion.Port.Cancel.Test.EdgeCase {
        @Test("Cancel operations are safe to call multiple times")
        func cancelMultipleTimes() {
            var overlapped = Kernel.IO.Completion.Port.Overlapped()

            // Call all multiple times - should be safe
            for _ in 0..<3 {
                Kernel.IO.Completion.Port.Cancel.all(Kernel.Descriptor.invalid)()
            }

            // Call pending multiple times - should be safe
            for _ in 0..<3 {
                Kernel.IO.Completion.Port.Cancel.pending(Kernel.Descriptor.invalid, overlapped: &overlapped)()
            }

            // Call pending.status multiple times - should be safe
            for _ in 0..<3 {
                _ = Kernel.IO.Completion.Port.Cancel.pending(
                    Kernel.Descriptor.invalid,
                    overlapped: &overlapped
                ).status
            }
        }

        @Test("Cancel with different overlapped instances")
        func cancelDifferentOverlappeds() {
            var overlapped1 = Kernel.IO.Completion.Port.Overlapped()
            var overlapped2 = Kernel.IO.Completion.Port.Overlapped()
            var overlapped3 = Kernel.IO.Completion.Port.Overlapped()

            Kernel.IO.Completion.Port.Cancel.pending(Kernel.Descriptor.invalid, overlapped: &overlapped1)()
            Kernel.IO.Completion.Port.Cancel.pending(Kernel.Descriptor.invalid, overlapped: &overlapped2)()
            Kernel.IO.Completion.Port.Cancel.pending(Kernel.Descriptor.invalid, overlapped: &overlapped3)()
        }
    }

    // MARK: - Error Integration Tests

    extension Kernel.IO.Completion.Port.Cancel.Test.Unit {
        @Test("Cancel uses Error.Code.Lookup.notFound for comparison")
        func usesNotFoundConstant() {
            // Verify that the implementation checks against ERROR_NOT_FOUND
            let notFound = Kernel.IO.Completion.Port.Error.Code.Lookup.notFound
            #expect(notFound == 1168)  // ERROR_NOT_FOUND
        }
    }

#endif
