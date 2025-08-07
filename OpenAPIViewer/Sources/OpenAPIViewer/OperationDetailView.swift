//
//  OperationDetailView.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 29/07/2025.
//

import SwiftUI
import SwiftOpenAPI
import RichTextView

struct OperationDetailView: View {
  let path: String
  let operation: HTTPMethod
  @Binding var document: OpenAPI.Document
  
  @Environment(\.editMode) private var isEditMode
  
  private var pathItem: OpenAPI.PathItem {
    document[path: path]
  }
  
  private var operationDetails: OpenAPI.Operation? {
    pathItem[method: operation]
  }
  
  private var operationDescriptionBinding: Binding<String> {
    $document[path: path][method: operation].description.defaultingToEmptyString
  }
  
  private var operationSummaryBinding: Binding<String> {
    $document[path: path][method: operation].summary.defaultingToEmptyString
  }
  
  private var methodColor: Color {
    switch operation {
    case .get: return .blue
    case .post: return .green
    case .put: return .orange
    case .delete: return .red
    case .patch: return .purple
    case .head, .options, .trace: return .gray
    }
  }
  
  private func addRequestBody() {
    let newRequestBody = OpenAPI.RequestBody(
      description: nil,
      content: [:],
      required: nil
    )
    let requestBodyRef = OpenAPI.Referenceable<OpenAPI.RequestBody>.value(newRequestBody)
    document[path: path][method: operation].requestBody = requestBodyRef
  }
  
  var body: some View {
    GeometryReader { geometry in
      HStack(spacing: 0) {
        // Main content area
        ScrollView {
          VStack(alignment: .leading, spacing: 20) {
            // Header with method and path
            VStack(alignment: .leading, spacing: 8) {
              HStack {
                Text(operation.rawValue)
                  .font(.title2.bold())
                  .foregroundColor(.white)
                  .padding(.horizontal, 12)
                  .padding(.vertical, 6)
                  .background(methodColor)
                  .cornerRadius(8)
                
                Text(path)
                  .font(.title2.monospaced())
                  .foregroundColor(.primary)

                Spacer()
              }
              
              if operationDetails?.summary != nil || isEditMode {
                if isEditMode {
                  TextField("Operation summary", text: operationSummaryBinding)
                    .font(.title3)
                    .textFieldStyle(.plain)
                    .foregroundColor(.secondary)
                } else {
                  Text(operationDetails?.summary ?? "")
                    .font(.title3)
                    .foregroundColor(.secondary)
                }
              }
            }
            
            // Description
            if operationDetails?.description != nil || isEditMode {
              VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                  .font(.headline)
                
                MarkdownTextView(markdown: operationDescriptionBinding, editable: isEditMode)
                  .font(.body)
                  .foregroundColor(.secondary)
              }
            }
            
            // Parameters
            if let parameters = operationDetails?.parameters, !parameters.isEmpty {
              VStack(alignment: .leading, spacing: 8) {
                Text("Parameters")
                  .font(.headline)
                
                ForEach(Array(parameters.enumerated()), id: \.offset) { _, parameterRef in
                  if let parameter = parameterRef.resolve(in: document) {
                    ParameterRow(parameter: parameter)
                  }
                }
              }
            }
            
            // Request Body
            if let requestBody = operationDetails?.requestBody?.resolve(in: document) {
              RequestBodyExampleView(
                requestBody: requestBody,
                document: $document,
                path: path,
                operation: operation
              )
            } else if isEditMode {
              // Add Request Body button in edit mode
              VStack(alignment: .leading, spacing: 8) {
                Text("Request Body")
                  .font(.headline)
                
                Button(action: addRequestBody) {
                  Label("Add Request Body", systemImage: "plus.circle")
                    .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
              }
            }
            
            Spacer()
          }
          .padding()
        }
        .frame(width: geometry.size.width * 0.5)

        // Vertical divider
        Divider()
        
        // Example Response section
        ExampleResponseView(
          operation: operationDetails,
          document: document
        )
        .frame(width: geometry.size.width * 0.5)
      }
    }
  }
}

extension Optional where Wrapped == String {
  var defaultingToEmptyString: String {
    get { self ?? "" }
    set {
      if newValue == "" {
        self = .none
      } else {
        self = .some(newValue)
      }
    }
  }
}
