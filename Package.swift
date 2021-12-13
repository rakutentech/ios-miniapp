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
        .package(url: "https://github.com/Climbatize/GoogleMobileAds.git" , .upToNextMajor(from: "8.12.0"))
    ],
    targets: [
        .binaryTarget(
            name: "MiniApp",
            url: "https://github.com/rakutentech/ios-miniapp/releases/download/v3.9.0/MiniApp.xcframework.zip",
            checksum: "8764c367820a108ef73097cb7125b931ab7026f6b536cfa81db26f8cd3a81703"
        )
    ],
    swiftLanguageVersions: [
        .v5
    ]
)