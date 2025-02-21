// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyFirebase",
    platforms: [
        .macOS(.v14), .iOS(.v13), .tvOS(.v13)
    ],
    products: [
        .library(
            name: "SwiftyFirebase",
            targets: ["SwiftyFirebase"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.8.1")
    ],
    targets: [
        .target(
            name: "SwiftyFirebase",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk")
            ]
        ),
        .testTarget(
            name: "SwiftyFirebaseTests",
            dependencies: ["SwiftyFirebase"]
        ),
    ]
)
