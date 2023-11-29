// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WebDAVKit",
    platforms: [.iOS(.v15), .macOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "WebDAVKit",
            targets: ["WebDAVKit"]),
    ],
    dependencies: [
          .package(url: "https://github.com/drmohundro/SWXMLHash", from: "6.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "WebDAVKit",
            dependencies: [.byName(name: "SWXMLHash")]),
        .testTarget(
            name: "WebDAVKitTests",
            dependencies: ["WebDAVKit"]),
    ]
)
