import Foundation
import ArgumentParser
import SwiftOpenAPI

@main
struct OpenAPIParser: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "open-api-parser",
    abstract: "A tool for parsing and analyzing OpenAPI specifications",
    subcommands: [ListPaths.self]
  )
}

struct ListPaths: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "list-paths",
    abstract: "List all paths defined in an OpenAPI specification"
  )
  
  @Option(name: .long, help: "The directory containing the OpenAPI specification")
  var directory: String
  
  func run() throws {
    let url = URL(fileURLWithPath: directory)
    let fileWrapper = try FileWrapper(url: url)
    
    print("Attempting to parse OpenAPI document from: \(url.path)")
    do {
      let document = try OpenAPI.Document.from(fileWrapper: fileWrapper)
      print("Successfully parsed document")
    } catch {
      print("Error parsing document: \(error)")
      if let decodingError = error as? DecodingError {
        print("Decoding error details:")
        switch decodingError {
        case .typeMismatch(let type, let context):
          print("  Type mismatch: expected \(type)")
          print("  Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
          print("  Debug description: \(context.debugDescription)")
        case .valueNotFound(let type, let context):
          print("  Value not found: \(type)")
          print("  Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
        case .keyNotFound(let key, let context):
          print("  Key not found: \(key)")
          print("  Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
        case .dataCorrupted(let context):
          print("  Data corrupted")
          print("  Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
          print("  Debug description: \(context.debugDescription)")
        @unknown default:
          print("  Unknown decoding error")
        }
      }
      throw error
    }
    let document = try! OpenAPI.Document.from(fileWrapper: fileWrapper)
    
    print("OpenAPI Specification: \(document.openapi)")
    print("API Title: \(document.info.title)")
    print("API Version: \(document.info.version)")
    print()
    
    if let paths = document.paths, !paths.isEmpty {
      print("Paths:")
      let sortedPaths = paths.keys.sorted()
      for path in sortedPaths {
        print("  \(path)")
        
        // Get the path item
        if let pathItemRef = paths[path],
           let pathItem = pathItemRef.resolve(in: document) {
          
          // List operations for this path
          let operations = [
            (HTTPMethod.get, pathItem.get),
            (HTTPMethod.post, pathItem.post),
            (HTTPMethod.put, pathItem.put),
            (HTTPMethod.delete, pathItem.delete),
            (HTTPMethod.patch, pathItem.patch),
            (HTTPMethod.head, pathItem.head),
            (HTTPMethod.options, pathItem.options),
            (HTTPMethod.trace, pathItem.trace)
          ]
          
          for (method, operation) in operations {
            if let op = operation {
              let summary = op.summary ?? "No summary"
              print("    \(method.rawValue): \(summary)")
            }
          }
        }
      }
      print("\nTotal paths: \(paths.count)")
    } else {
      print("No paths found in the specification.")
    }
    
    // Also check componentFiles for external path items
    if let componentFiles = document.componentFiles,
       let pathItems = componentFiles.pathItems,
       !pathItems.isEmpty {
      print("\nExternal Path Items (in componentFiles):")
      let sortedPaths = pathItems.keys.sorted()
      for path in sortedPaths {
        print("  \(path)")
      }
      print("Total external path items: \(pathItems.count)")
    }
  }
}