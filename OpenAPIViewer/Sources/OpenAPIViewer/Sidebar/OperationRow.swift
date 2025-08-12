//
//  OperationRow.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 30/07/2025.
//

import SwiftUI
import SwiftOpenAPI

struct OperationRow: View {
  let method: HTTPMethod
  let path: String
  let operation: OpenAPI.Operation
  let indentLevel: Int
  let onDelete: (String, String) -> Void
  
  private var methodColor: Color {
    switch method {
    case .get: return .blue
    case .post: return .green
    case .put: return .orange
    case .delete: return .red
    case .patch: return .purple
    case .head, .options, .trace: return .gray
    }
  }
  
  var body: some View {
    HStack(spacing: 8) {
      // HTTP method badge
      Text(method.rawValue)
        .font(.system(size: 10, weight: .bold))
        .foregroundColor(.white)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(methodColor)
        .cornerRadius(3)
      
      // Path
      Text(path)
        .font(.system(size: 12, design: .monospaced))
        .foregroundColor(.primary)
      
      Spacer(minLength: 0)
    }
    .padding(.leading, CGFloat(indentLevel * 8))
    .padding(.vertical, 3)
    .tag("\(path)|\(method.rawValue)")
    .contextMenu {
      Button("Delete Operation", role: .destructive) {
        onDelete(path, method.rawValue)
      }
    }
  }
}
