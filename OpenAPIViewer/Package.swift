// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "OpenAPIViewer",
  products: [
    .library(name: "OpenAPIViewer", targets: ["OpenAPIViewer"])
  ],
  targets: [
    .target(name: "OpenAPIViewer"),
    .testTarget(name: "OpenAPIViewerTests", dependencies: [
      "OpenAPIViewer"
    ]),
  ]
)
