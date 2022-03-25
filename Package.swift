// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "MiniApp",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "MiniApp", targets: ["MiniApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.0")),
        .package(url: "https://github.com/datatheorem/TrustKit.git", .upToNextMajor(from: "2.0.0")),
        .package(name: "GoogleMobileAds-SPM", url: "https://github.com/rakutentech/GoogleMobileAds-SPM.git", .upToNextMajor(from: "9.0.0"))
    ],
    targets: [
        .target(
            name: "MiniApp",
            dependencies: [
                "ZIPFoundation",
                "TrustKit",
                .product(name: "GoogleMobileAds", package: "GoogleMobileAds-SPM")
            ],
            path: "Sources/Classes/",
            exclude: [
                "admob7/AdMobDisplayer.swift"
            ],
            resources: [
                .process("resources")
            ]
        )
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
