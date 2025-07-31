// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "OpenAPIViewer",
  platforms: [
    .macOS(.v15)
  ],
  products: [
    .library(name: "OpenAPIViewer", targets: ["OpenAPIViewer"])
  ],
  dependencies: [
    .package(path: "../SwiftOpenAPI"),
    .package(path: "../../RichTextView"),
    .package(url: "https://github.com/imben123/swift-collections", branch: "feature/ordered-dictionary-codable-strategy")
  ],
  targets: [
    .target(
      name: "OpenAPIViewer",
      dependencies: [
        "SwiftOpenAPI",
        "RichTextView",
        .product(name: "Collections", package: "swift-collections")
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
