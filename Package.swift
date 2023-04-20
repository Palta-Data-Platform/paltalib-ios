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
    )
]

let dependencies: [Package.Dependency] = [
    .package(
        url: "https://github.com/amplitude/Amplitude-iOS.git",
        from: "8.5.0"
    ),
    .package(
        url: "https://github.com/Palta-Data-Platform/paltalib-swift-core.git",
        from: "3.1.1"
    )

]

let targets: [Target] = [
    .target(
        name: "PaltaLibAnalytics",
        dependencies: [
            .product(name: "PaltaCore", package: "paltalib-swift-core"),
            .product(name: "Amplitude", package: "Amplitude-iOS")
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
