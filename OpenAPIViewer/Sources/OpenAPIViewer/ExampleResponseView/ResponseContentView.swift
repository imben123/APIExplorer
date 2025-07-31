//
//  ResponseContentView.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 30/07/2025.
//

import SwiftUI
import SwiftOpenAPI

struct ResponseContentView: View {
  let content: [String: OpenAPI.MediaType]
  let document: OpenAPI.Document
  
  var body: some View {
    ForEach(Array(content.keys), id: \.self) { mediaTypeName in
      if let mediaType = content[mediaTypeName] {
        ResponseMediaTypeView(
          mediaTypeName: mediaTypeName,
          mediaType: mediaType,
          document: document
        )
      }
    }
  }
}
