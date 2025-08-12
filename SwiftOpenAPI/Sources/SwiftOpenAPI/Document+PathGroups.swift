//
//  Document+PathGroups.swift
//  SwiftOpenAPI
//
//  Created by Ben Davis on 30/07/2025.
//

import Foundation
import Collections

public extension OpenAPI {
  struct PathItemGroup {
    let name: String
    let items: [String]
    let groups: [PathItemGroup]
  }
}

public extension OpenAPI.Document {
  var ungroupedPathItems: [String] {
    guard let paths else {
      return []
    }
    var result: [String] = []
    for path in paths.keys {
      switch paths[path]! {
      case .value:
        result.append(path)
      case .reference(let ref):
        let normalizedRef = ref.removingPrefix("./")
        let rootFiles = componentFiles?.pathItems?.items.keys ?? []
        if ref.starts(with: "#") || rootFiles.contains(normalizedRef) {
          result.append(path)
        }
      }
    }
    return result
  }

  var groupedPathItems: OrderedDictionary<String, OpenAPI.PathGroup> {
    guard let paths, let rootGroup = componentFiles?.pathItems else {
      return [:]
    }
    let filePaths = paths.keys
      .compactMap { paths[$0]!.ref }
      .filter { !$0.starts(with: "#") }
      .map { $0.removingPrefix("./") }
    return rootGroup.groups.mapValues { $0.filtered(byPaths: filePaths) }
  }

  subscript(filePath filePath: String) -> OpenAPI.PathItem {
    get {
      let path = path(for: filePath)!
      return self[path: path]
    }
    set {
      guard let path = path(for: filePath) else {
        return
      }
      self[path: path] = newValue
    }
  }

  func path(for filePath: String) -> String? {
    return paths?.first { (key, value) in
      guard let ref = value.ref else {
        return false
      }
      return filePath == ref.removingPrefix("./")
    }?.key
  }
}

extension OpenAPI.PathGroup {
  func filtered<T: Collection>(byPaths paths: T) -> Self where T.Element == String {
    .init(
      items: items.filter { paths.contains($0.key) },
      groups: groups.mapValues { $0.filtered(byPaths: paths) }
    )
  }
}
