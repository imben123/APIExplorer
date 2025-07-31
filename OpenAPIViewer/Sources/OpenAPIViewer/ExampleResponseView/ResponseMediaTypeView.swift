//
//  ResponseMediaTypeView.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 30/07/2025.
//

import SwiftUI
import SwiftOpenAPI

struct ResponseMediaTypeView: View {
  let mediaTypeName: String
  let mediaType: OpenAPI.MediaType
  let document: OpenAPI.Document
  
  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(mediaTypeName)
        .font(.caption.monospaced())
        .foregroundColor(.secondary)
        .padding(.horizontal)
      
      ResponseExampleContentView(
        mediaType: mediaType,
        document: document
      )
      .padding(.horizontal)
    }
  }
}
