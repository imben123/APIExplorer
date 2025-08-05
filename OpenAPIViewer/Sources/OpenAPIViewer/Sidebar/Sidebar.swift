//
//  Sidebar.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 29/07/2025.
//

import SwiftUI
import SwiftOpenAPI
import Collections
import SwiftToolbox

struct Sidebar: View {
  let document: OpenAPI.Document
  @Binding var selectedPath: String?
  @Binding var selectedOperation: String?
  @Binding var selectedServer: String
  @Binding var serverVariableValues: OrderedDictionary<String, String>

  var body: some View {
    VStack(spacing: 0) {
      // Environment picker at the top
      if let servers = document.servers, !servers.isEmpty {
        EnvironmentPicker(
          servers: servers,
          selectedServerURL: $selectedServer,
          serverVariableValues: $serverVariableValues
        )
        
        Divider()
      }
      
      // Paths list
      PathsList(
        document: document,
        selectedPath: $selectedPath,
        selectedOperation: $selectedOperation
      )
    }
    .navigationTitle("API Explorer")
  }
}

#Preview {
  NavigationSplitView(sidebar: {
    Sidebar(
      document: sampleDocument,
      selectedPath: .constant(nil),
      selectedOperation: .constant(nil),
      selectedServer: .constant("/"),
      serverVariableValues: .constant(.init())
    )
    .frame(minWidth: 260)
  }, detail: {
    Text("")
  })
}
