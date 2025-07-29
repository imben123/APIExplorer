//
//  ContentView.swift
//  APIExplorer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftUI

struct ContentView: View {
  @Binding var document: SwaggerDocument

  var body: some View {
    Text(document.yamlString)
      .font(.system(.body, design: .monospaced))
      .navigationTitle("Swagger Document")
  }
}

#Preview {
  ContentView(document: .constant(SwaggerDocument(string: "openapi: \"3.1.1\"\ninfo:\n  title: Sample API\n  version: \"1.0.0\"")))
}
