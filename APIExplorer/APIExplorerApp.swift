//
//  APIExplorerApp.swift
//  APIExplorer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftUI

@main
struct APIExplorerApp: App {
  
  init() {
    // Enable NSOpenPanel folder selection
    NSOpenPanel.enableFolderSelection()
    NSDocument.performSwizzles()
  }
  
  var body: some Scene {
    DocumentGroup(newDocument: OpenAPIDocument()) { file in
      ContentView(document: file.$document)
    }
    .defaultSize(width: 1450, height: 1010)
  }
}
