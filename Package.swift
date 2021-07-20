// swift-tools-version:5.3.0

import PackageDescription

let name: String = "PaltaLib"

let platforms: [SupportedPlatform] = [
    .iOS(.v10),
    .tvOS(.v9),
    .macOS(.v10_10)
]

let products: [Product] = [
    .library(
        name: "PaltaLib",
        targets: [
            "PaltaLib"
        ]
    )
]

let dependencies: [Package.Dependency] = [
    .package(name: "Amplitude", url: "https://github.com/amplitude/Amplitude-iOS.git", from: "8.3.0")
]

let targets: [Target] = [
    .target(
        name: "PaltaLib",
        dependencies: [
            .product(name: "Amplitude", package: "Amplitude")
        ]
    )
]

let package = Package(
    name: name,
    platforms: platforms,
    products: products,
    dependencies: dependencies,
    targets: targets
)
