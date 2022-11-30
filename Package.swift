// swift-tools-version:5.6

import PackageDescription

let package = Package(
  name: "swift-declarative-configuration",
  platforms: [
    .iOS(.v11),
    .macOS(.v10_13),
    .tvOS(.v11),
    .macCatalyst(.v13),
    .watchOS(.v4),
  ],
  products: [
    .library(
      name: "DeclarativeConfiguration",
      targets: ["DeclarativeConfiguration"]
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
  targets: [
    .target(
      name: "DeclarativeConfiguration",
      dependencies: [
        .target(name: "FunctionalBuilder"),
        .target(name: "FunctionalConfigurator"),
        .target(name: "FunctionalClosures"),
        .target(name: "FunctionalKeyPath"),
        .target(name: "FunctionalModification"),
      ]
    ),
    .target(
      name: "FunctionalBuilder",
      dependencies: [
        .target(name: "FunctionalConfigurator"),
        .target(name: "FunctionalKeyPath"),
        .target(name: "FunctionalModification"),
      ]
    ),
    .target(
      name: "FunctionalConfigurator",
      dependencies: [
        .target(name: "FunctionalKeyPath"),
        .target(name: "FunctionalModification"),
      ]
    ),
    .target(name: "FunctionalClosures"),
    .target(
      name: "FunctionalKeyPath",
      dependencies: [
        .target(name: "FunctionalModification"),
      ]
    ),
    .target(name: "FunctionalModification"),
    .testTarget(
      name: "DeclarativeConfigurationTests",
      dependencies: [
        .target(name: "DeclarativeConfiguration"),
      ]
    ),
  ]
)
