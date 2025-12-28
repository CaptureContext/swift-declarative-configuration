// swift-tools-version:5.10

import PackageDescription

let package = Package(
	name: "swift-declarative-configuration",
	platforms: [
		.iOS(.v13),
		.macOS(.v10_15),
		.tvOS(.v13),
		.watchOS(.v6),
		.macCatalyst(.v13),
	],
	products: [
		.library(
			name: "DeclarativeConfiguration",
			targets: ["DeclarativeConfiguration"]
		),
		.library(
			name: "DeclarativeConfigurationCore",
			targets: ["DeclarativeConfigurationCore"]
		),
		.library(
			name: "FunctionalBuilder",
			targets: ["FunctionalBuilder"]
		),
		.library(
			name: "FunctionalConfigurator",
			targets: ["FunctionalConfigurator"]
		),
		.library(
			name: "FunctionalClosures",
			targets: ["FunctionalClosures"]
		),
		.library(
			name: "FunctionalKeyPath",
			targets: ["FunctionalKeyPath"]
		),
		.library(
			name: "FunctionalModification",
			targets: ["FunctionalModification"]
		),
	],
	dependencies: [
		.package(
			url: "https://github.com/pointfreeco/xctest-dynamic-overlay",
			.upToNextMajor(from: "1.8.0")
		),
	],
	targets: [
		.target(
			name: "DeclarativeConfiguration",
			dependencies: [
				.target(name: "DeclarativeConfigurationCore"),
				.target(name: "FunctionalClosures"),
				.product(
					name: "IssueReporting",
					package: "xctest-dynamic-overlay"
				)
			]
		),

		.target(name: "DeclarativeConfigurationCore"),

		.testTarget(
			name: "DeclarativeConfigurationTests",
			dependencies: [
				.target(name: "DeclarativeConfiguration"),
			]
		),

		.testTarget(
			name: "DeclarativeConfigurationCoreTests",
			dependencies: [
				.target(name: "DeclarativeConfigurationCore"),
			]
		),

		// MARK: - Deprecated

		.target(
			name: "FunctionalClosures",
			path: "Sources/Deprecated/FunctionalClosures"
		),

		.target(
			name: "FunctionalBuilder",
			dependencies: [
				.target(name: "DeclarativeConfiguration"),
			],
			path: "Sources/Deprecated/FunctionalBuilder"
		),

		.target(
			name: "FunctionalConfigurator",
			dependencies: [
				.target(name: "DeclarativeConfiguration"),
			],
			path: "Sources/Deprecated/FunctionalConfigurator"
		),

		.target(
			name: "FunctionalKeyPath",
			dependencies: [
				.target(name: "DeclarativeConfigurationCore"),
			],
			path: "Sources/Deprecated/FunctionalKeyPath"
		),

		.target(
			name: "FunctionalModification",
			path: "Sources/Deprecated/FunctionalModification"
		),
	]
)
