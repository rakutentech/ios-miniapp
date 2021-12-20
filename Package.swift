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
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9")),
        .package(url: "https://github.com/datatheorem/TrustKit"),
        .package(url: "https://github.com/Climbatize/GoogleMobileAds.git" , .upToNextMajor(from: "8.13.0"))
    ],
    targets: [
        .binaryTarget(
            name: "MiniApp",
            url: "https://github.com/rakutentech/ios-miniapp/releases/download/v3.9.0/MiniApp.xcframework.zip"
        )
    ],
    swiftLanguageVersions: [
        .v5
    ]
)