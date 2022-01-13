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
            "PaltaLibCore",
            "PaltaLibAnalytics",
            "PaltaLibPurchases",
            "PaltaLibAttribution"
        ]
    )
]

let dependencies: [Package.Dependency] = [
    .package(name: "Amplitude", url: "https://github.com/amplitude/Amplitude-iOS.git", from: "8.5.0"),
    .package(name: "Purchases", url: "https://github.com/RevenueCat/purchases-ios.git", from: "3.13.0"),
    .package(name: "AppsFlyerLib", url: "https://github.com/AppsFlyerSDK/AppsFlyerFramework.git", from: "6.4.2")
]

let targets: [Target] = [
    .target(
        name: "PaltaLibCore",
        path: "Sources/Core"
    ),
    .target(
        name: "PaltaLibAnalytics",
        dependencies: [
            "PaltaLibCore",
            "Amplitude"
        ],
        path: "Sources/Analytics"
    ),
    .target(
        name: "PaltaLibPurchases",
        dependencies: [
            "PaltaLibCore",
            "PaltaLibAnalytics",
            "PaltaLibAttribution",
            "Purchases",
        ],
        path: "Sources/Purchases"
    ),
    .target(
        name: "PaltaLibAttribution",
        dependencies: [
            "PaltaLibCore",
            "AppsFlyerLib"
        ],
        path: "Sources/Attribution"
    )
]

let package = Package(
    name: name,
    platforms: platforms,
    products: products,
    dependencies: dependencies,
    targets: targets
)
