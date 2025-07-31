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
  let response: OpenAPI.Response
  let document: OpenAPI.Document
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("HTTP \(statusCode)")
        .font(.subheadline.bold())
        .padding(.horizontal)
      
      MarkdownTextView(markdown: response.description)
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(.horizontal)
      
      if let content = response.content {
        ResponseContentView(content: content, document: document)
      }
    }
    .padding(.vertical, 8)
  }
}
