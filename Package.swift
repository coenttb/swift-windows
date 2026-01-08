// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-windows",
    products: [
        .library(
            name: "Windows Primitives",
            targets: ["Windows Primitives"]
        ),
        .library(
            name: "Windows Kernel",
            targets: ["Windows Kernel"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/coenttb/swift-kernel-primitives.git", from: "0.1.0"),
        .package(url: "https://github.com/swift-standards/swift-standards.git", from: "0.29.0")
    ],
    targets: [
        .target(
            name: "Windows Primitives",
            dependencies: []
        ),
        .target(
            name: "Windows Kernel",
            dependencies: [
                .target(name: "Windows Primitives"),
                .product(name: "Kernel Primitives", package: "swift-kernel-primitives"),
            ]
        ),
        .testTarget(
            name: "Windows Kernel Tests",
            dependencies: [
                "Windows Kernel",
                .product(name: "Kernel Primitives Test Support", package: "swift-kernel-primitives"),
                .product(name: "StandardsTestSupport", package: "swift-standards")
            ],
            path: "Tests/Windows Kernel Tests"
        ),
    ]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility")
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
