//
//  OpenAPIDocumentView.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 29/07/2025.
//

import SwiftUI
import SwiftOpenAPI
import Collections

public struct OpenAPIDocumentView: View {
  @Binding var document: OpenAPI.Document
  
  @State private var selectedPath: String?
  @State private var selectedOperation: String?
  @State private var isEditMode: Bool = false
  
  public init(document: Binding<OpenAPI.Document>) {
    self._document = document
  }
  
  public var body: some View {
    NavigationSplitView(sidebar: {
      // Left sidebar with paths
      PathsSidebar(
        document: document,
        selectedPath: $selectedPath,
        selectedOperation: $selectedOperation
      )
      .frame(minWidth: 260)
    }, detail: {
      // Main content area
      if let selectedPath = selectedPath,
         let selectedOperation = selectedOperation,
         let httpMethod = HTTPMethod(rawValue: selectedOperation) {
        
        OperationDetailView(
          path: selectedPath,
          operation: httpMethod,
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
