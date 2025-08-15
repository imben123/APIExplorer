//
//  DocumentSerialization.swift
//  SwiftOpenAPI
//
//  Created by Ben Davis on 05/08/2025.
//

import Foundation
import Collections
import SwiftUI
import SwiftToolbox
import Yams

public extension OpenAPI.Document {
  /// Serializes the OpenAPI document to a FileWrapper for writing to disk
  /// - Parameter configuration: The write configuration containing content type information
  /// - Returns: A FileWrapper containing the serialized document
  /// - Throws: Error if serialization fails
  func serialize(configuration: FileDocument.WriteConfiguration) throws -> FileWrapper {
    // Check if we should write as a directory
    guard configuration.contentType == .folder else {
      return try serializeAsFile(configuration: configuration)
    }
    
    return try serializeAsDirectory(configuration: configuration)
  }
}

// MARK: - Private Helper Functions

private extension OpenAPI.Document {
  
  /// Serializes the document as a single file
  func serializeAsFile(configuration: FileDocument.WriteConfiguration) throws -> FileWrapper {
    // Sort the paths before serialization to ensure consistent output
    var sortedDocument = self
    sortedDocument.sortDocumentPaths()
    
    let format: SerializationFormat = configuration.contentType == .json ? .json : .yaml
    let data = try sortedDocument.serialize(format: format)
    
    // Check if we have stored hash and it matches the new serialized data
    if let originalHash = _originalDataHash.value,
       data.calculateHash() == originalHash,
       let existingFile = configuration.existingFile,
       !existingFile.isDirectory,
       let originalData = existingFile.regularFileContents {
      // Content hasn't changed semantically, return original data to preserve formatting
      return FileWrapper(regularFileWithContents: originalData)
    } else {
      // Content has changed, update the hash
      _originalDataHash.value = data.calculateHash()
    }
    
    return FileWrapper(regularFileWithContents: data)
  }
  
  /// Serializes the document as a directory structure
  func serializeAsDirectory(configuration: FileDocument.WriteConfiguration) throws -> FileWrapper {
    // Sort the paths before serialization to ensure consistent output
    var sortedDocument = self
    sortedDocument.sortDocumentPaths()
    
    // Create directory wrapper
    let directoryWrapper = FileWrapper(directoryWithFileWrappers: [:])
    
    // Determine the main file format - prefer YAML for directories
    let mainFileName = "openapi.yaml"
    let mainFileData = try sortedDocument.serialize(format: .yaml)
    
    // Check if we can reuse the existing main file
    let finalMainFileData = sortedDocument.getFinalMainFileData(
      mainFileData: mainFileData,
      mainFileName: mainFileName,
      configuration: configuration
    )
    
    directoryWrapper.addRegularFile(withContents: finalMainFileData, preferredFilename: mainFileName)
    
    // Add component files if available
    if let componentFiles = sortedDocument.componentFiles {
      try sortedDocument.addComponentFilesToDirectory(
        directoryWrapper: directoryWrapper,
        componentFiles: componentFiles,
        mainFileName: mainFileName,
        configuration: configuration
      )
    }
    
    // Add other files if available
    if let otherFiles = sortedDocument.otherFiles {
      sortedDocument.addOtherFilesToDirectory(
        directoryWrapper: directoryWrapper,
        otherFiles: otherFiles,
        mainFileName: mainFileName
      )
    }
    
    return directoryWrapper
  }
  
  /// Gets the final main file data, reusing original if unchanged
  func getFinalMainFileData(
    mainFileData: Data,
    mainFileName: String,
    configuration: FileDocument.WriteConfiguration
  ) -> Data {
    if let originalHash = _originalDataHash.value,
       mainFileData.calculateHash() == originalHash,
       let existingFile = configuration.existingFile,
       existingFile.isDirectory,
       let existingMainFile = existingFile.fileWrappers?[mainFileName],
       let existingMainData = existingMainFile.regularFileContents {
      // Main file hasn't changed semantically, reuse original data to preserve formatting
      return existingMainData
    } else {
      // Content has changed, update the hash
      _originalDataHash.value = mainFileData.calculateHash()
      return mainFileData
    }
  }
  
  /// Adds component files to the directory wrapper
  func addComponentFilesToDirectory(
    directoryWrapper: FileWrapper,
    componentFiles: OpenAPI.Components,
    mainFileName: String,
    configuration: FileDocument.WriteConfiguration
  ) throws {
    
    // Add all component types
    addComponentFiles(componentFiles.schemas?.compactMapValues({ $0.value }), to: directoryWrapper, mainFileName: mainFileName, configuration: configuration)
    addComponentFiles(componentFiles.responses?.compactMapValues({ $0.value }), to: directoryWrapper, mainFileName: mainFileName, configuration: configuration)
    addComponentFiles(componentFiles.parameters?.compactMapValues({ $0.value }), to: directoryWrapper, mainFileName: mainFileName, configuration: configuration)
    addComponentFiles(componentFiles.examples?.compactMapValues({ $0.value }), to: directoryWrapper, mainFileName: mainFileName, configuration: configuration)
    addComponentFiles(componentFiles.requestBodies?.compactMapValues({ $0.value }), to: directoryWrapper, mainFileName: mainFileName, configuration: configuration)
    addComponentFiles(componentFiles.headers?.compactMapValues({ $0.value }), to: directoryWrapper, mainFileName: mainFileName, configuration: configuration)
    addComponentFiles(componentFiles.securitySchemes?.compactMapValues({ $0.value }), to: directoryWrapper, mainFileName: mainFileName, configuration: configuration)
    addComponentFiles(componentFiles.links?.compactMapValues({ $0.value }), to: directoryWrapper, mainFileName: mainFileName, configuration: configuration)
    addComponentFiles(componentFiles.callbacks?.compactMapValues({ $0.value }), to: directoryWrapper, mainFileName: mainFileName, configuration: configuration)

    if let rootGroup = componentFiles.pathItems {
      // Recursively add path items from the group structure
      addPathItemsFromGroup(
        rootGroup,
        to: directoryWrapper,
        basePath: [],
        mainFileName: mainFileName,
        configuration: configuration
      )
    }
  }
  
  /// Adds component files of a specific type to the directory
  func addComponentFiles<T: Encodable>(
    _ files: OrderedDictionary<String, T>?,
    to directoryWrapper: FileWrapper,
    mainFileName: String,
    configuration: FileDocument.WriteConfiguration
  ) {
    guard let files = files else { return }
    
    for (filePath, component) in files {
      // Skip the main OpenAPI file to avoid duplication
      if filePath == mainFileName {
        continue
      }
      
      let encoder = YAMLEncoder.default
      encoder.orderedDictionaryCodingStrategy = .keyedContainer
      let newData = try! encoder.encode(component).data(using: .utf8)!
      
      // Check if component conforms to ComponentFileSerializable and has an originalDataHash
      let finalData: Data
      if let serializableComponent = component as? ComponentFileSerializable,
         let originalHash = serializableComponent.originalDataHash,
         newData.calculateHash() == originalHash,
         let originalData = getOriginalData(for: filePath, from: configuration.existingFile) {
        // Component hasn't changed semantically, reuse original data
        finalData = originalData
      } else {
        finalData = newData
      }
      
      addFileToDirectoryStructure(
        data: finalData,
        filePath: filePath,
        to: directoryWrapper
      )
    }
  }
  
  /// Recursively adds path items from a PathGroup
  func addPathItemsFromGroup(
    _ group: OpenAPI.PathGroup,
    to directoryWrapper: FileWrapper,
    basePath: [String],
    mainFileName: String,
    configuration: FileDocument.WriteConfiguration
  ) {
    // Add items directly in this group
    for (filePath, referenceablePathItem) in group.items {
      // Skip the main OpenAPI file to avoid duplication
      if filePath == mainFileName {
        continue
      }

      // Extract the PathItem from the Referenceable
      guard case let .value(pathItem) = referenceablePathItem else {
        continue // Skip references, only handle direct values
      }

      let encoder = YAMLEncoder.default
      encoder.orderedDictionaryCodingStrategy = .keyedContainer
      let newData = try! encoder.encode(pathItem).data(using: .utf8)!

      // The filePath is already the full path (e.g., "paths/group1/penguin.yaml")
      // We just need to use it directly
      let actualFilePath = filePath

      // Check if PathItem has an originalDataHash for change detection
      let finalData: Data
      if let originalHash = pathItem.originalDataHash,
         newData.calculateHash() == originalHash,
         let originalData = getOriginalData(for: actualFilePath, from: configuration.existingFile) {
        // PathItem hasn't changed semantically, reuse original data
        finalData = originalData
      } else {
        finalData = newData
      }

      addFileToDirectoryStructure(
        data: finalData,
        filePath: actualFilePath,
        to: directoryWrapper
      )
    }
    
    // Recursively add items from subgroups
    for (groupName, subgroup) in group.groups {
      let newBasePath = basePath + [groupName]
      
      // Create empty directory if the group has no items
      if subgroup.items.isEmpty {
        // Create the directory structure for empty groups
        let dirPath = "paths/" + newBasePath.joined(separator: "/")
        createEmptyDirectoryStructure(dirPath: dirPath, to: directoryWrapper)
      }
      
      addPathItemsFromGroup(
        subgroup,
        to: directoryWrapper,
        basePath: newBasePath,
        mainFileName: mainFileName,
        configuration: configuration
      )
    }
  }
  
  /// Creates an empty directory structure
  func createEmptyDirectoryStructure(dirPath: String, to directoryWrapper: FileWrapper) {
    let pathComponents = dirPath.split(separator: "/").map(String.init)
    var currentWrapper = directoryWrapper
    
    for pathComponent in pathComponents {
      if let existingDir = currentWrapper.fileWrappers?[pathComponent] {
        currentWrapper = existingDir
      } else {
        let newDir = FileWrapper(directoryWithFileWrappers: [:])
        newDir.preferredFilename = pathComponent
        currentWrapper.addFileWrapper(newDir)
        currentWrapper = newDir
      }
    }
  }
  
  /// Adds other files to the directory
  func addOtherFilesToDirectory(
    directoryWrapper: FileWrapper,
    otherFiles: OrderedDictionary<String, Data>,
    mainFileName: String
  ) {
    for (filePath, data) in otherFiles {
      // Skip the main OpenAPI file to avoid duplication
      if filePath == mainFileName {
        continue
      }
      
      addFileToDirectoryStructure(
        data: data,
        filePath: filePath,
        to: directoryWrapper
      )
    }
  }
  
  
  /// Retrieves original data from existing file structure
  func getOriginalData(for filePath: String, from existingFile: FileWrapper?) -> Data? {
    guard let existingFile = existingFile, existingFile.isDirectory else { return nil }
    
    let pathComponents = filePath.split(separator: "/").map(String.init)
    var currentWrapper = existingFile
    
    // Navigate through directory structure
    for (index, component) in pathComponents.enumerated() {
      if index == pathComponents.count - 1 {
        // Last component is the file - get its data
        return currentWrapper.fileWrappers?[component]?.regularFileContents
      } else {
        // Directory component - navigate deeper
        guard let nextWrapper = currentWrapper.fileWrappers?[component] else {
          return nil
        }
        currentWrapper = nextWrapper
      }
    }
    return nil
  }
  
  /// Adds a file to the directory structure, creating intermediate directories as needed
  func addFileToDirectoryStructure(
    data: Data,
    filePath: String,
    to directoryWrapper: FileWrapper
  ) {
    let pathComponents = filePath.split(separator: "/").map(String.init)
    addFileToDirectoryStructure(data: data, pathComponents: pathComponents, to: directoryWrapper)
  }
  
  /// Adds a file to the directory structure using path components
  func addFileToDirectoryStructure(
    data: Data,
    pathComponents: [String],
    to directoryWrapper: FileWrapper
  ) {
    var currentWrapper = directoryWrapper
    
    // Navigate/create directory structure
    for (index, pathComponent) in pathComponents.enumerated() {
      if index == pathComponents.count - 1 {
        // Last component is the file
        currentWrapper.addRegularFile(withContents: data, preferredFilename: pathComponent)
      } else {
        // Directory component
        if let existingDir = currentWrapper.fileWrappers?[pathComponent] {
          currentWrapper = existingDir
        } else {
          let newDir = FileWrapper(directoryWithFileWrappers: [:])
          newDir.preferredFilename = pathComponent
          currentWrapper.addFileWrapper(newDir)
          currentWrapper = newDir
        }
      }
    }
  }
}
