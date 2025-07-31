// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "SwiftOpenAPI",
  platforms: [
    .macOS(.v11)
  ],
  products: [
    .library(name: "SwiftOpenAPI", targets: ["SwiftOpenAPI"]),
    .executable(name: "open-api-parser", targets: ["OpenAPIParser"]),
    .executable(name: "test-ordered-dict", targets: ["TestOrderedDict"])
  ],
  dependencies: [
    .package(url: "https://github.com/imben123/SwiftToolbox", branch: "main"),
    .package(url: "https://github.com/imben123/Yams", branch: "main"),
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    .package(url: "https://github.com/imben123/swift-collections", branch: "feature/ordered-dictionary-codable-strategy")
  ],
  targets: [
    .target(name: "SwiftOpenAPI", dependencies: [
      "SwiftToolbox", 
      "Yams",
      .product(name: "Collections", package: "swift-collections")
    ]),
    .executableTarget(
      name: "OpenAPIParser",
      dependencies: [
        "SwiftOpenAPI",
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ]
    ),
    .executableTarget(
      name: "TestOrderedDict",
      dependencies: [
        "SwiftOpenAPI",
        "SwiftToolbox",
        "Yams",
        .product(name: "Collections", package: "swift-collections")
      ]
    ),
    .testTarget(name: "SwiftOpenAPITests", dependencies: [
      "SwiftOpenAPI"
    ], resources: [
      .copy("comprehensive-openapi.yaml"),
      .copy("comprehensive-openapi.json")
    ]),
  ]
)
