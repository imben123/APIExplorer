//
//  NewEnvironmentSheet.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 05/08/2025.
//

import SwiftUI
import SwiftOpenAPI

struct NewEnvironmentSheet: View {
  @Binding var isPresented: Bool
  let onSave: (String, String) -> Void
  
  @State private var name: String = ""
  @State private var url: String = ""
  
  var body: some View {
    VStack(spacing: 0) {
      // Header
      HStack {
        Button("Cancel") {
          isPresented = false
        }
        
        Spacer()
        
        Text("Add Environment")
          .font(.headline)
        
        Spacer()
        
        Button("Add") {
          onSave(url, name)
          isPresented = false
        }
        .disabled(name.isEmpty || url.isEmpty)
        .buttonStyle(.borderedProminent)
      }
      .padding()
      .background(Color(NSColor.windowBackgroundColor))
      
      Divider()
      
      // Content
      VStack(alignment: .leading, spacing: 16) {
        Text("New Environment")
          .font(.title2)
          .fontWeight(.semibold)
        
        VStack(alignment: .leading, spacing: 12) {
          VStack(alignment: .leading, spacing: 4) {
            Text("Environment Name")
              .font(.headline)
            TextField("e.g., Production, Development", text: $name)
              .textFieldStyle(.roundedBorder)
          }
          
          VStack(alignment: .leading, spacing: 4) {
            Text("Server URL")
              .font(.headline)
            TextField("https://api.example.com", text: $url)
              .textFieldStyle(.roundedBorder)
              .autocorrectionDisabled()
          }
        }
        
        Text("Enter a descriptive name and the base URL for this environment.")
          .font(.caption)
          .foregroundColor(.secondary)
        
        Spacer()
      }
      .padding()
    }
    .frame(width: 500, height: 350)
  }
}

#Preview {
  NewEnvironmentSheet(
    isPresented: .constant(true),
    onSave: { url, name in
      print("Save: \(name) - \(url)")
    }
  )
}
