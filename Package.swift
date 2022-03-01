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
            checksum: "c514a23a41915c08c18681a61403ad81294e0d281a3a591bf6c99c9c9755bcc4"
            dependencies: ["ZIPFoundation", "TrustKit", "GoogleMobileAds-SPM"]
        )
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
