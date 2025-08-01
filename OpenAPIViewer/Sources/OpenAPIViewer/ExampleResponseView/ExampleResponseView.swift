//
//  ExampleResponseView.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 29/07/2025.
//

import SwiftUI
import SwiftOpenAPI
import SwiftToolbox
import Collections

struct ExampleResponseView: View {
  let operation: OpenAPI.Operation?
  let document: OpenAPI.Document
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        Text("Example Responses")
          .font(.headline)
          .padding(.horizontal)
        
        if let responses = operation?.responses {
          ForEach(Array(responses.responses.keys.sorted()), id: \.self) { statusCode in
            if let responseRef = responses.responses[statusCode],
               let response = responseRef.resolve(in: document) {
              // Similar to parameters, only direct values can be edited properly
              // References would need more complex handling
              switch responseRef {
              case .value(let response):
                ResponseStatusView(
                  statusCode: statusCode,
                  response: Binding(
                    get: { response },
                    set: { _ in
                      // TODO: Implement proper response reference editing
                    }
                  ),
                  document: document
                )
              case .reference:
                ResponseStatusView(
                  statusCode: statusCode,
                  response: .constant(response),
                  document: document
                )
              }
            }
          }
        } else {
          Text("No responses defined")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal)
        }
        
        Spacer()
      }
      .padding(.top)
    }
    .background(.secondary.opacity(0.05))
  }
}
