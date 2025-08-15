//
//  GroupHeadingView.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 15/08/2025.
//

import SwiftUI

struct GroupHeadingView: View {
  let name: String
  let level: Int
  let groupPath: [String]
  let isCollapsed: Bool
  let isEditMode: Bool
  let onToggle: () -> Void
  let onAddPath: () -> Void
  
  var body: some View {
    HStack(spacing: 0) {
      Button(action: onToggle) {
        HStack(spacing: 6) {
          Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(.secondary)
            .frame(width: 12)
          Text(name)
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(.primary)
          Spacer()
        }
        .padding(.vertical, 4)
        .padding(.leading, CGFloat(level * 16))
        .contentShape(Rectangle())
      }
      .buttonStyle(PlainButtonStyle())
      
      if isEditMode {
        Button(action: onAddPath) {
          Image(systemName: "plus")
            .font(.system(size: 11))
            .foregroundColor(.secondary)
            .frame(width: 20, height: 20)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.trailing, 8)
      }
    }
  }
}