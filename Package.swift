// swift-tools-version:5.3.0

import PackageDescription

let name: String = "PaltaLib"

let platforms: [SupportedPlatform] = [
    .iOS(.v10)
//    .tvOS(.v9),
//    .macOS(.v10_10)
]

let products: [Product] = [
    .library(
        name: "PaltaLibAttribution",
        targets: [
            "PaltaLibAttribution"
        ]
    ),
    .library(
        name: "PaltaLibPurchases",
        targets: [
            "PaltaLibPurchases"
        ]
    ),
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
    .package(name: "Amplitude", url: "https://github.com/amplitude/Amplitude-iOS.git", from: "8.5.0"),
    .package(name: "Purchases", url: "https://github.com/RevenueCat/purchases-ios.git", from: "3.13.0"),
    .package(name: "AppsFlyerLib", url: "https://github.com/AppsFlyerSDK/AppsFlyerFramework.git", from: "6.4.2")
]

let targets: [Target] = [
    .target(
        name: "PaltaLibCore",
        dependencies: [],
        path: "Sources/Core"
    ),
    .target(
        name: "PaltaLibAttribution",
        dependencies: [
            "AppsFlyerLib"
        ],
        path: "Sources/Attribution"
    ),
    .target(
        name: "PaltaLibPurchases",
        dependencies: [
            "Purchases",
            "PaltaLibCore",
            "PaltaLibAttribution"
        ],
        path: "Sources/Purchases"
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
