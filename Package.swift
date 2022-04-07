// swift-tools-version:5.1

import PackageDescription

var dependencies: [Package.Dependency] = [
	.package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.0.0")
]
var targetDependencies: [Target.Dependency] = ["RxSwift", "RxRelay"]

#if os(Linux)
dependencies.append(.package(url: "https://github.com/cx-org/CombineX", from: "0.4.0"))
targetDependencies.append("CombineX")
#endif

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
	dependencies: dependencies,
	targets: [
		.target(
			name: "RxCombine",
			dependencies: targetDependencies,
			path: "Sources"),
		.testTarget(
			name: "RxCombineTests",
			dependencies: ["RxCombine"],
			path: "Tests"
		)
	]
)
