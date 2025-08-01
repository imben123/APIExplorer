//
//  ResponseStatusView.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 30/07/2025.
//

import SwiftUI
import SwiftOpenAPI
import RichTextView

struct ResponseStatusView: View {
  let statusCode: String
  @Binding var response: OpenAPI.Response
  let document: OpenAPI.Document
  
  @Environment(\.editMode) private var isEditMode
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("HTTP \(statusCode)")
        .font(.subheadline.bold())
        .padding(.horizontal)
      
      if isEditMode {
        MarkdownTextView(markdown: Binding(
          get: { response.description },
          set: { response.description = $0 }
        ), editable: true)
          .font(.caption)
          .foregroundColor(.secondary)
          .padding(.horizontal)
      } else {
        MarkdownTextView(markdown: response.description)
          .font(.caption)
          .foregroundColor(.secondary)
          .padding(.horizontal)
      }
      
      if let content = response.content {
        ResponseContentView(content: content, document: document)
      }
    }
    .padding(.vertical, 8)
  }
}
