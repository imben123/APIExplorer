//
//  EnvironmentPicker.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 05/08/2025.
//

import SwiftUI
import SwiftOpenAPI
import Collections
import SwiftToolbox

struct EnvironmentPicker: View {
  let servers: [OpenAPI.Server]
  @Binding var selectedServerURL: String
  @Binding var serverVariableValues: OrderedDictionary<String, String>
  let onAddServer: (String, String) -> Void
  let onDeleteServer: (String) -> Void
  @State private var isExpanded: Bool = false
  @State private var showingNewEnvironmentSheet: Bool = false
  @State private var showingDeleteConfirmation: Bool = false
  @State private var serverToDelete: OpenAPI.Server?
  
  @Environment(\.editMode) private var editMode
  
  private var selectedServer: OpenAPI.Server? {
    servers.first(where: { $0.url == selectedServerURL })
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      DisclosureGroup(isExpanded: $isExpanded) {
        VStack(alignment: .leading, spacing: 12) {
          // Server picker or empty state
          if !servers.isEmpty {
            HStack {
              Picker("Environment", selection: $selectedServerURL) {
                ForEach(servers.indices, id: \.self) { index in
                  Text(servers[index].description ?? servers[index].url)
                    .tag(servers[index].url)
                }
                
                if editMode {
                  Divider()
                  Button("Create New Environment...") {
                    showingNewEnvironmentSheet = true
                  }
                  .tag("__create_new__")
                }
              }
              .pickerStyle(.menu)
              .labelsHidden()
              .onChange(of: selectedServerURL) { oldValue, newValue in
                if newValue == "__create_new__" {
                  selectedServerURL = oldValue
                  showingNewEnvironmentSheet = true
                }
              }
              
              if editMode && servers.count > 1 && selectedServer != nil {
                Button(action: {
                  serverToDelete = selectedServer
                  showingDeleteConfirmation = true
                }) {
                  Image(systemName: "trash")
                    .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .help("Delete selected environment")
              }
              
              Spacer()
            }
            
            // Show the URL
            if selectedServer != nil {
              Text(resolvedURL)
                .font(.caption)
                .foregroundColor(.secondary)
                .textSelection(.enabled)
            }
            
            // Server variables
            if let server = selectedServer,
               let variables = server.variables,
               !variables.isEmpty {
              Divider()
              
              VStack(alignment: .leading, spacing: 8) {
                ForEach(variables.keys, id: \.self) { key in
                  if let variable = variables[key] {
                    ServerVariableEditor(
                      name: key,
                      variable: variable,
                      value: Binding(
                        get: { serverVariableValues[key] ?? variable.default },
                        set: { serverVariableValues[key] = $0 }
                      )
                    )
                  }
                }
              }
            }
          } else {
            VStack(alignment: .leading, spacing: 8) {
              Text("No servers defined")
                .font(.caption)
                .foregroundColor(.secondary)

              if editMode {
                Button("Create New Environment") {
                  showingNewEnvironmentSheet = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
              }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
          }
        }
        .padding(.top, 4)
      } label: {
        HStack {
          Text("Environment")
            .font(.headline)
          Spacer()
          if !isExpanded, let server = selectedServer {
            Text(server.description ?? "Server")
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
      }
    }
    .padding(.horizontal)
    .padding(.vertical, 8)
    .sheet(isPresented: $showingNewEnvironmentSheet) {
      NewEnvironmentSheet(
        isPresented: $showingNewEnvironmentSheet,
        onSave: { url, name in
          onAddServer(url, name)
          selectedServerURL = url
        }
      )
    }
    .confirmationDialog(
      "Delete Environment",
      isPresented: $showingDeleteConfirmation,
      titleVisibility: .visible,
      presenting: serverToDelete
    ) { server in
      Button("Delete", role: .destructive) {
        // Select a different server before deleting
        if let firstOtherServer = servers.first(where: { $0.url != server.url }) {
          selectedServerURL = firstOtherServer.url
        }
        onDeleteServer(server.url)
      }
      Button("Cancel", role: .cancel) {}
    } message: { server in
      Text("Are you sure you want to delete \"\(server.description ?? server.url)\"? This cannot be undone.")
    }
    .onAppear {
      if let server = servers.first {
        selectedServerURL = server.url
      }
    }
  }
  
  private var resolvedURL: String {
    guard let server = selectedServer else { return "/" }
    var url = server.url
    
    if let variables = server.variables {
      for (key, variable) in variables {
        let value = serverVariableValues[key] ?? variable.default
        url = url.replacingOccurrences(of: "{\(key)}", with: value)
      }
    }
    
    return url
  }
}

struct ServerVariableEditor: View {
  let name: String
  let variable: OpenAPI.ServerVariable
  @Binding var value: String

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(name)
        .font(.caption)
        .fontWeight(.medium)
      
      if let enumValues = variable.enum, !enumValues.isEmpty {
        // Dropdown for enum values
        Picker(name, selection: $value) {
          ForEach(enumValues, id: \.self) { enumValue in
            Text(enumValue).tag(enumValue)
          }
        }
        .pickerStyle(.menu)
        .labelsHidden()
        .frame(maxWidth: .infinity, alignment: .leading)
      } else {
        // Text field for string values
        TextField(name, text: $value)
          .textFieldStyle(.roundedBorder)
          .font(.caption)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      
      if let description = variable.description {
        Text(description)
          .font(.caption2)
          .foregroundColor(.secondary)
      }
    }
  }
}

#Preview {
  VStack {
    EnvironmentPicker(
      servers: [
        OpenAPI.Server(
          url: "https://api.example.com",
          description: "Production"
        ),
        OpenAPI.Server(
          url: "https://dev.example.com",
          description: "Development",
          variables: [
            "version": OpenAPI.ServerVariable(
              enum: ["v1", "v2", "v3"],
              default: "v2",
              description: "API version"
            ),
            "port": OpenAPI.ServerVariable(
              default: "8080",
              description: "Server port"
            )
          ]
        )
      ],
      selectedServerURL: .constant("https://dev.example.com"),
      serverVariableValues: .constant([:]),
      onAddServer: { url, name in
        print("Add server: \(name) - \(url)")
      },
      onDeleteServer: { url in
        print("Delete server: \(url)")
      }
    )
    .frame(width: 300)
    
    Spacer()
  }
}
