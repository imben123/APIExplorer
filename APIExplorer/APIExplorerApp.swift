//
//  APIExplorerApp.swift
//  APIExplorer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftUI

@main
struct APIExplorerApp: App {
  var body: some Scene {
    DocumentGroup(newDocument: SwaggerDocument()) { file in
      ContentView(document: file.$document)
    }
  }
}
