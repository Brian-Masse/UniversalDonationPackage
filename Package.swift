// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UniversalDonationPackage",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "UniversalDonationPackage",
            targets: ["UniversalDonationPackage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Brian-Masse/UIUniversals", from: "1.0.1")
    ],
    
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "UniversalDonationPackage",
            dependencies: ["UIUniversals"],
            path: "Sources",
            resources: [
                .process("Resources")
            ]),
        .testTarget(
            name: "UniversalDonationPackageTests",
            dependencies: ["UniversalDonationPackage"]),
    ]
)
