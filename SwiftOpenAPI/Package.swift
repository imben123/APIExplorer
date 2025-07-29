// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "SwiftOpenAPI",
  products: [
    .library(name: "SwiftOpenAPI", targets: ["SwiftOpenAPI"]),
  ],
  dependencies: [
    .package(url: "https://github.com/imben123/SwiftToolbox", branch: "main"),
    .package(url: "https://github.com/jpsim/Yams", from: "5.0.0")
  ],
  targets: [
    .target(name: "SwiftOpenAPI", dependencies: ["SwiftToolbox", "Yams"]),
    .testTarget(name: "SwiftOpenAPITests", dependencies: [
      "SwiftOpenAPI"
    ], resources: [
      .copy("comprehensive-openapi.yaml"),
      .copy("comprehensive-openapi.json")
    ]),
  ]
)
