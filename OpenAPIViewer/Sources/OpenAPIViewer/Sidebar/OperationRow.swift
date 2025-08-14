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
  let onDelete: (String, HTTPMethod) -> Void
  let includeDropIndicator: Bool
  var includeRootDropDestination: Bool = false

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
    VStack(spacing: 0) {
      if includeRootDropDestination {
        DropIndicatorLine(spaceBelow: true)
      }
      
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
      .padding(.vertical, 3)

      if includeDropIndicator {
        DropIndicatorLine()
      }
    }
    .padding(.leading, CGFloat(indentLevel * 8))
    .tag("\(path)|\(method.rawValue)")
    .contextMenu {
      Button("Delete Operation", role: .destructive) {
        onDelete(path, method)
      }
    }
  }
}

struct DropIndicatorLine: View {

  var spaceBelow: Bool = false

  var body: some View {
    Rectangle()
      .fill(Color.blue.opacity(0.5))
      .frame(height: 2)
      .padding(spaceBelow ? .top : .bottom, -2)
  }
}
