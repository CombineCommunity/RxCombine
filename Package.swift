// swift-tools-version:5.1

import PackageDescription

#if os(Linux)
let package = Package(
    name: "RxCombine",
    platforms: [
        .macOS(.v10_10), .iOS(.v9), .tvOS(.v9), .watchOS(.v3)
    ],
    products: [
        .library(
            name: "RxCombine",
            targets: ["RxCombine"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.0.0"),
		.package(url: "https://github.com/cx-org/CombineX", from: "0.4.0")

    ],
    targets: [
        .target(
            name: "RxCombine",
            dependencies: ["RxSwift", "RxRelay", "CombineX"],
            path: "Sources"),
        .testTarget(
            name: "RxCombineTests",
            dependencies: ["RxCombine"],
            path: "Tests"
        )
    ]
)
#else
let package = Package(
	name: "RxCombine",
	platforms: [
		.macOS(.v10_10), .iOS(.v9), .tvOS(.v9), .watchOS(.v3)
	],
	products: [
		.library(
			name: "RxCombine",
			targets: ["RxCombine"]),
	],
	dependencies: [
		.package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.0.0")
	],
	targets: [
		.target(
			name: "RxCombine",
			dependencies: ["RxSwift", "RxRelay"],
			path: "Sources"),
		.testTarget(
			name: "RxCombineTests",
			dependencies: ["RxCombine"],
			path: "Tests"
		)
	]
)
#endif
