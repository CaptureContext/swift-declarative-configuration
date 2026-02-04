// swift-tools-version: 6.0

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

		// MARK: - Deprecated

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
			url: "https://github.com/capturecontext/swift-keypaths-extensions.git",
			.upToNextMinor(from: "0.1.5")
		),
		.package(
			url: "https://github.com/pointfreeco/xctest-dynamic-overlay.git",
			.upToNextMajor(from: "1.8.0")
		),
	],
	targets: [
		.target(
			name: "DeclarativeConfiguration",
			dependencies: [
				.target(name: "DeclarativeConfigurationCore"),
				.target(name: "FunctionalClosures"),
			]
		),

		.target(
			name: "DeclarativeConfigurationCore",
			dependencies: [
				.product(
					name: "KeyPathsExtensions",
					package: "swift-keypaths-extensions"
				),
				.product(
					name: "IssueReporting",
					package: "xctest-dynamic-overlay"
				),
			]
		),

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
			dependencies: [
				.target(name: "DeclarativeConfigurationCore"),
			],
			path: "Sources/Deprecated/FunctionalModification"
		),
	],
	swiftLanguageModes: [.v6]
)
