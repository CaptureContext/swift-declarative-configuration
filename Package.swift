// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "swift-declarative-configuration",
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
    .target(name: "FunctionalKeyPath"),
    .target(name: "FunctionalModification"),
    .testTarget(
      name: "DeclarativeConfigurationTests",
      dependencies: [
        .target(name: "DeclarativeConfiguration")
      ]
    ),
  ]
)
