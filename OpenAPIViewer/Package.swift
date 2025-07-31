// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "OpenAPIViewer",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .library(name: "OpenAPIViewer", targets: ["OpenAPIViewer"])
  ],
  dependencies: [
    .package(path: "../SwiftOpenAPI")
  ],
  targets: [
    .target(
      name: "OpenAPIViewer",
      dependencies: [
        "SwiftOpenAPI"
      ],
      resources: [
        .process("Resources")
      ],
      swiftSettings: [
        .defaultIsolation(MainActor.self)
      ]
    ),
    .testTarget(name: "OpenAPIViewerTests", dependencies: [
      "OpenAPIViewer"
    ]),
  ]
)
