//
//  OpenAPIDocumentView.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 29/07/2025.
//

import SwiftUI
import SwiftOpenAPI
import Collections
import SwiftToolbox

public struct OpenAPIDocumentView: View {
  @Binding var document: OpenAPI.Document
  
  @State private var selectedPath: String?
  @State private var selectedOperation: HTTPMethod?
  @State private var isEditMode: Bool = false

  @State private var selectedServer: String = "/"
  @State var serverVariableValues: OrderedDictionary<String, String> = .init()

  public init(document: Binding<OpenAPI.Document>) {
    self._document = document
    if let server = document.wrappedValue.servers?.first {
      self.selectedServer = server.url
      self.serverVariableValues = .init()
    }
  }
  
  public var body: some View {
    NavigationSplitView(sidebar: {
      // Left sidebar
      Sidebar(
        document: $document,
        selectedPath: $selectedPath,
        selectedOperation: $selectedOperation,
        selectedServer: $selectedServer,
        serverVariableValues: $serverVariableValues
      )
      .frame(minWidth: 260)
    }, detail: {
      // Main content area
      if let selectedPath = selectedPath,
         let selectedOperation = selectedOperation {
        
        OperationDetailView(
          path: selectedPath,
          operation: selectedOperation,
          document: $document
        )
      } else {
        VStack(spacing: 16) {
          Image(systemName: "doc.text")
            .font(.system(size: 64))
            .foregroundColor(.secondary)
          
          VStack(spacing: 8) {
            Text("Select an Operation")
              .font(.title2)
              .fontWeight(.semibold)
            
            Text("Choose a path and operation from the sidebar to view details")
              .font(.body)
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    })
    .environment(\.editMode, isEditMode)
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button {
          isEditMode.toggle()
        } label: {
          Image(systemName: isEditMode ? "checkmark.circle.fill" : "pencil.circle")
        }
      }
    }
  }
}
