//
//  ParameterRow.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 29/07/2025.
//

import SwiftUI
import SwiftOpenAPI
import RichTextView

struct ParameterRow: View {
  let parameter: OpenAPI.Parameter
  
  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack {
        Text(parameter.name)
          .font(.system(.body, design: .monospaced))
          .bold()
        
        if parameter.required == true {
          Text("required")
            .font(.caption)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(.red)
            .cornerRadius(4)
        }
        
        Spacer()
        
        Text(parameter.in.rawValue)
          .font(.caption)
          .foregroundColor(.secondary)
          .padding(.horizontal, 6)
          .padding(.vertical, 2)
          .background(.secondary.opacity(0.1))
          .cornerRadius(4)
      }
      
      if let description = parameter.description {
        MarkdownTextView(markdown: description)
          .font(.caption)
          .foregroundColor(.secondary)
      }
    }
    .padding(.vertical, 4)
  }
}
