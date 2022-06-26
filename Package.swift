// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private let dependencies: [Target.Dependency] = []

let package = Package(
    name: "Deeplinks",
	platforms: [.iOS(.v13)],
    products: [
		.library(name: "Deeplinks", type: .dynamic, targets: ["Deeplinks"]),
    ],
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Deeplinks",
            dependencies: dependencies,
			path: "./Deeplinks/Classes",
			resources: []),
        .testTarget(
            name: "DeeplinksTests",
            dependencies: dependencies,
			path: "./Deeplinks/Tests",
			resources: []),
    ]
)
