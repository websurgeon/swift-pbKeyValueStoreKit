// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PBKeyValueKit",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "PBKeyValueKit",
            targets: ["PBKeyValueKit"]),
        
        .library(
            name: "PBKeyValueStore",
            targets: ["PBKeyValueStore"]),
        
        .library(
            name: "PBKeyValueStoreTesting",
            targets: ["PBKeyValueStoreTesting"]),
        
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "PBKeyValueKit",
            dependencies: ["PBKeyValueStore"]),
        .testTarget(
            name: "PBKeyValueKitTests",
            dependencies: ["PBKeyValueKit", "PBKeyValueStoreTesting"]),
        
        .target(
            name: "PBKeyValueStore",
            dependencies: []),
        .testTarget(
            name: "PBKeyValueStoreTests",
            dependencies: ["PBKeyValueStore", "PBKeyValueStoreTesting"]),
        
        .target(
            name: "PBKeyValueStoreTesting",
            dependencies: ["PBKeyValueStore"]),
        .testTarget(
            name: "PBKeyValueStoreTestingTests",
            dependencies: ["PBKeyValueStoreTesting"]),
    ]
)
