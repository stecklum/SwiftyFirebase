// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let packageName = "SwiftyFirebase"
let firebasePackageName = "firebase-ios-sdk"

let package = Package(
    name: packageName,
    platforms: [
        .macOS(.v14), .iOS(.v17), .tvOS(.v17)
    ],
    products: [
        .library(
            name: packageName,
            targets: [packageName]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/\(firebasePackageName)", from: "11.8.1")
    ],
    targets: [
        .target(
            name: packageName,
            dependencies: [
                .product(name: "FirebaseAuth", package: firebasePackageName),
                .product(name: "FirebaseFirestore", package: firebasePackageName),
                .product(name: "FirebaseStorage", package: firebasePackageName),
                .product(name: "FirebaseAnalytics", package: firebasePackageName)
            ]
        ),
        .testTarget(
            name: "SwiftyFirebaseTests",
            dependencies: ["SwiftyFirebase"]
        ),
    ]
)
