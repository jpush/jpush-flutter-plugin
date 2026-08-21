// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "jpush_flutter",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "jpush-flutter", targets: ["jpush_flutter"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/jpush/jcore-sdk.git", from: "5.5.1"),
        .package(url: "https://github.com/jpush/jpush-sdk.git", exact: "6.2.2")
    ],
    targets: [
        .target(
            name: "jpush_flutter",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "JCore", package: "jcore-sdk"),
                .product(name: "JPush", package: "jpush-sdk")
            ],
            cSettings: [
                .headerSearchPath("include/jpush_flutter")
            ]
        )
    ]
)
