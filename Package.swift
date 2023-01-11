// swift-tools-version:5.3.0

import PackageDescription

let name: String = "PaltaLib"

let platforms: [SupportedPlatform] = [
    .iOS(.v11)
]

let products: [Product] = [
    .library(
        name: "PaltaLibAnalytics",
        targets: [
            "PaltaLibAnalytics"
        ]
    ),
    .library(
        name: "PaltaLibCore",
        targets: [
            "PaltaLibCore"
        ]
    )
]

let dependencies: [Package.Dependency] = [
    .package(name: "Amplitude", url: "https://github.com/amplitude/Amplitude-iOS.git", from: "8.5.0")
]

let targets: [Target] = [
    .target(
        name: "PaltaLibCore",
        dependencies: [],
        path: "Sources/Core"
    ),
    .target(
        name: "PaltaLibAnalytics",
        dependencies: [
            "Amplitude",
            "PaltaLibCore"
        ],
        path: "Sources/Analytics"
    )
]

let package = Package(
    name: name,
    platforms: platforms,
    products: products,
    dependencies: dependencies,
    targets: targets
)
