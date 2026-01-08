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
public import Kernel_Primitives

#if os(Windows)
    public import WinSDK

    extension Kernel.IOCP.Completion {
        /// Completion key for routing I/O completions to handlers.
        ///
        /// The completion key is an application-defined value associated with
        /// a file handle when it's registered with an IOCP. When a completion
        /// arrives, the key identifies which handle completed the operation.
        ///
        /// ## Common Patterns
        ///
        /// **Index-based:** Use small integers to index into an array of handlers:
        /// ```swift
        /// let handlers: [Handler] = ...
        /// let key = Kernel.IOCP.Completion.Key(UInt(handlerIndex))
        /// try Kernel.IOCP.associate(port, handle: fileHandle, key: key)
        ///
        /// // On completion:
        /// let handler = handlers[Int(entry.key.rawValue)]
        /// ```
        ///
        /// **Pointer-based:** Store a pointer to context directly:
        /// ```swift
        /// let context = UnsafeMutablePointer<MyContext>.allocate(capacity: 1)
        /// context.initialize(to: MyContext(...))
        /// let key = Kernel.IOCP.Completion.Key(pointer: context)
        /// try Kernel.IOCP.associate(port, handle: fileHandle, key: key)
        ///
        /// // On completion:
        /// let context = UnsafeMutablePointer<MyContext>(
        ///     bitPattern: UInt(entry.key.rawValue)
        /// )!
        /// ```
        ///
        /// ## See Also
        ///
        /// - ``Kernel/IOCP``
        /// - ``Kernel/IOCP/Entry``
        public struct Key: RawRepresentable, Sendable, Equatable, Hashable {
            public let rawValue: ULONG_PTR

            @inlinable
            public init(rawValue: ULONG_PTR) {
                self.rawValue = rawValue
            }
        }
    }

    // MARK: - Pointer Conversions

    extension Kernel.IOCP.Completion.Key {
        /// Creates a completion key from an integer identifier.
        ///
        /// - Parameter id: An integer identifier for the key.
        @inlinable
        public init(_ id: ULONG_PTR) {
            self.init(rawValue: id)
        }

        /// Creates a completion key from a raw pointer.
        ///
        /// This is useful when you want to associate a context object
        /// with a handle.
        ///
        /// - Parameter pointer: A pointer to associate with the handle.
        @inlinable
        public init(_ pointer: UnsafeRawPointer) {
            self.init(rawValue: ULONG_PTR(UInt(bitPattern: pointer)))
        }

        /// Creates a completion key from a typed pointer.
        ///
        /// - Parameter pointer: A pointer to associate with the handle.
        @inlinable
        public init<T>(pointer: UnsafePointer<T>) {
            self.init(rawValue: ULONG_PTR(UInt(bitPattern: pointer)))
        }

        /// Creates a completion key from a mutable typed pointer.
        ///
        /// - Parameter pointer: A mutable pointer to associate with the handle.
        @inlinable
        public init<T>(pointer: UnsafeMutablePointer<T>) {
            self.init(rawValue: ULONG_PTR(UInt(bitPattern: pointer)))
        }
    }

    // MARK: - Common Values

    extension Kernel.IOCP.Completion.Key {
        /// Zero completion key.
        public static let zero = Self(rawValue: 0)
    }

    // MARK: - ExpressibleByIntegerLiteral

    extension Kernel.IOCP.Completion.Key: ExpressibleByIntegerLiteral {
        @inlinable
        public init(integerLiteral value: UInt) {
            self.init(rawValue: ULONG_PTR(value))
        }
    }

#endif
