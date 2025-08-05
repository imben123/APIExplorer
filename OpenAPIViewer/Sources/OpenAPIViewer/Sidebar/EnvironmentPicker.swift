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
  @State private var isExpanded: Bool = true
  
  private var selectedServer: OpenAPI.Server? {
    servers.first(where: { $0.url == selectedServerURL })
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      DisclosureGroup(isExpanded: $isExpanded) {
        VStack(alignment: .leading, spacing: 12) {
          // Server picker
          if !servers.isEmpty {
            HStack {
              Picker("Environment", selection: $selectedServerURL) {
                ForEach(servers.indices, id: \.self) { index in
                  Text(servers[index].description ?? servers[index].url)
                    .tag(servers[index].url)
                }
              }
              .pickerStyle(.menu)
              .labelsHidden()
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
            Text("No servers defined")
              .font(.caption)
              .foregroundColor(.secondary)
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
      serverVariableValues: .constant([:])
    )
    .frame(width: 300)
    
    Spacer()
  }
}
