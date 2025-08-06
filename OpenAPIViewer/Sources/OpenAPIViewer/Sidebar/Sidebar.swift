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
  @Binding var document: OpenAPI.Document
  @Binding var selectedPath: String?
  @Binding var selectedOperation: String?
  @Binding var selectedServer: String
  @Binding var serverVariableValues: OrderedDictionary<String, String>

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      // Environment picker at the top
      EnvironmentPicker(
        servers: document.servers ?? [],
        selectedServerURL: $selectedServer,
        serverVariableValues: $serverVariableValues,
        onAddServer: { url, name in
          addNewServer(url: url, name: name)
        },
        onDeleteServer: { url in
          deleteServer(url: url)
        }
      )

      Divider()
      
      // Paths list
      PathsList(
        document: $document,
        selectedPath: $selectedPath,
        selectedOperation: $selectedOperation
      )
    }
    .navigationTitle("API Explorer")
  }
  
  private func addNewServer(url: String, name: String) {
    let newServer = OpenAPI.Server(url: url, description: name)
    var servers = document.servers ?? []
    servers.append(newServer)
    document.servers = servers
  }
  
  private func deleteServer(url: String) {
    var servers = document.servers ?? []
    servers.removeAll { $0.url == url }
    document.servers = servers
  }
}

#Preview {
  NavigationSplitView(sidebar: {
    Sidebar(
      document: .constant(sampleDocument),
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
