// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "MiniApp",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "MiniApp",
            targets: ["MiniApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.0")),
        .package(url: "https://github.com/datatheorem/TrustKit", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/rakutentech/GoogleMobileAds-SPM.git", .upToNextMajor(from: "8.13.0"))
    ],
    targets: [
        .binaryTarget(
            name: "MiniApp",
            url: "https://github.com/rakutentech/ios-miniapp/releases/download/v4.0.0/MiniApp.xcframework.zip",
            checksum: "58e27ec141a15ab6e611db18b684a6fac14274dc00a4d8ff79e685ac5e951bf9"
            dependencies: ["ZIPFoundation", "TrustKit", "GoogleMobileAds-SPM"]
        )
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
