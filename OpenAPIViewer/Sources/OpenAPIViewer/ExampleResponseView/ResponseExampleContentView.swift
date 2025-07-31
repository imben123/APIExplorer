//
//  ResponseExampleContentView.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 30/07/2025.
//

import SwiftUI
import SwiftOpenAPI
import SwiftToolbox

struct ResponseExampleContentView: View {
  let mediaType: OpenAPI.MediaType
  let document: OpenAPI.Document
  
  var body: some View {
    ScrollView([.horizontal]) {
      HStack {
        VStack(alignment: .leading, spacing: 8) {
          // Show single example if available
          if let example = mediaType.example {
            JSONView(json: example)
              .padding(12)
          }
          // Show named examples if available
          else if let examples = mediaType.examples, !examples.isEmpty {
            ForEach(Array(examples.keys.sorted()), id: \.self) { exampleKey in
              if let exampleRef = examples[exampleKey],
                 let example = exampleRef.resolve(in: document),
                 let value = example.value {
                VStack(alignment: .leading, spacing: 4) {
                  if let summary = example.summary {
                    Text(summary)
                      .font(.caption.bold())
                      .foregroundColor(.primary)
                  } else {
                    Text(exampleKey)
                      .font(.caption.bold())
                      .foregroundColor(.primary)
                  }
                  JSONView(json: .object(value))
                    .padding(12)
                }
                .padding(12)
              }
            }
          }
          // Fallback when no examples
          else {
            Text("No examples available")
              .font(.caption)
              .foregroundColor(.secondary)
              .padding(12)
          }
        }
        Spacer(minLength: 0)
      }
    }
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(.secondary.opacity(0.1))
    )
    .frame(maxWidth: .infinity, maxHeight: 600)
  }
}
