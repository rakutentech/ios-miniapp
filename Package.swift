// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "MiniApp",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "MiniApp", targets: ["MiniApp"])
        //.library(name: "MiniApp-Binary", targets: ["MiniApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.0")),
        .package(url: "https://github.com/datatheorem/TrustKit.git", .upToNextMajor(from: "2.0.0")),
        .package(name: "GoogleMobileAds-SPM", url: "https://github.com/rakutentech/GoogleMobileAds-SPM.git", .upToNextMajor(from: "9.0.0"))
    ],
    targets: [
        .target(
            name: "MiniApp-Static",
            dependencies: [
                "ZIPFoundation",
                "TrustKit",
                .product(name: "GoogleMobileAds", package: "GoogleMobileAds-SPM")
            ],
            path: "Sources/Classes/",
            exclude: [
                "core/Utilities/LoaderObjC.m",
                "admob7/AdMobDisplayer.swift"
            ]
        ),
        // issues
        // swift toolkit version (5.4.2 <> 5.5.2)
        // no such module GoogleMobileAds
        //.binaryTarget(
        //    name: "MiniApp",
        //    url: "https://github.com/rakutentech/ios-miniapp/releases/download/v4.0.0/MiniApp.xcframework.zip",
        //    checksum: "dbde912b6717dce3db5f7c5f3e1ecbc37cc9b54cede575fbad2f259b2c72b3be"
        //)
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
