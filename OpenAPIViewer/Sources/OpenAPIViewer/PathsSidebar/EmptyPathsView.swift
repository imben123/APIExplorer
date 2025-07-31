//
//  EmptyPathsView.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 30/07/2025.
//

import SwiftUI

struct EmptyPathsView: View {
  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "road.lanes.curved.left")
        .font(.system(size: 48))
        .foregroundColor(.secondary)
      
      VStack(spacing: 8) {
        Text("No Paths")
          .font(.title3)
          .fontWeight(.semibold)
        
        Text("This OpenAPI document doesn't define any paths")
          .font(.body)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}