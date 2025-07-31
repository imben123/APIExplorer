//
//  ContentView.swift
//  APIExplorer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftUI
import OpenAPIViewer
import AppToolbox
import SwiftOpenAPI

struct ContentView: View {
  @Binding var document: OpenAPIDocument

  var body: some View {
    OpenAPIDocumentView(document: $document.content)
      .window {
        $0?.setOpenAPIFileName(document.content.info.title)
      }
      .navigationTitle(document.content.info.title)
  }
}

#Preview {
  ContentView(document: .constant(OpenAPIDocument(string: "openapi: \"3.1.1\"\ninfo:\n  title: Sample API\n  version: \"1.0.0\"")))
}
