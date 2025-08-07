//
//  RequestBodyExampleView.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 31/07/2025.
//

import SwiftUI
import SwiftOpenAPI
import SwiftToolbox
import Collections
import RichTextView

struct RequestBodyExampleView: View {
  let requestBody: OpenAPI.RequestBody
  @Binding var document: OpenAPI.Document
  let path: String
  let operation: HTTPMethod

  @Environment(\.editMode) private var isEditMode

  private func deleteRequestBody() {
    document[path: path][method: operation].requestBody = nil
  }

  private func addDescription() {
    if case .value(var requestBodyValue) = document[path: path][method: operation].requestBody {
      requestBodyValue.description = "Request body description"
      document[path: path][method: operation].requestBody = .value(requestBodyValue)
    }
  }

  private var defaultContentTypes: [String] {
    ["application/json", "application/xml", "text/plain", "text/html", "multipart/form-data", "application/x-www-form-urlencoded"]
  }

  private func getNextContentType() -> String? {
    guard case .value(let requestBodyValue) = document[path: path][method: operation].requestBody else {
      return "application/json"
    }

    // First try application/json
    if !requestBodyValue.content.keys.contains("application/json") {
      return "application/json"
    }

    // Then try other default content types
    for contentType in defaultContentTypes {
      if !requestBodyValue.content.keys.contains(contentType) {
        return contentType
      }
    }

    // If all defaults exist, try empty string
    if !requestBodyValue.content.keys.contains("") {
      return ""
    }

    // All possible content types exist
    return nil
  }

  private func addContent() {
    guard let contentType = getNextContentType() else { return }

    if case .value(var requestBodyValue) = document[path: path][method: operation].requestBody {
      var newContent = requestBodyValue.content
      newContent[contentType] = OpenAPI.MediaType()
      requestBodyValue.content = newContent
      document[path: path][method: operation].requestBody = .value(requestBodyValue)
    }
  }

  private func renameContentType(from oldKey: String, to newKey: String) {
    guard oldKey != newKey else { return }

    if case .value(var requestBodyValue) = document[path: path][method: operation].requestBody {
      var newContent = OrderedDictionary<String, OpenAPI.MediaType>()

      // Preserve order while renaming
      for (key, value) in requestBodyValue.content {
        if key == oldKey {
          newContent[newKey] = value
        } else {
          newContent[key] = value
        }
      }

      requestBodyValue.content = newContent
      document[path: path][method: operation].requestBody = .value(requestBodyValue)
    }
  }

  private func deleteContentType(_ contentType: String) {
    if case .value(var requestBodyValue) = document[path: path][method: operation].requestBody {
      requestBodyValue.content.removeValue(forKey: contentType)
      document[path: path][method: operation].requestBody = .value(requestBodyValue)
    }
  }

  private func renameExample(in contentType: String, from oldKey: String, to newKey: String) {
    guard oldKey != newKey else { return }

    if case .value(var requestBodyValue) = document[path: path][method: operation].requestBody,
       var mediaType = requestBodyValue.content[contentType],
       var examples = mediaType.examples {

      var newExamples = OrderedDictionary<String, OpenAPI.Referenceable<OpenAPI.Example>>()

      // Preserve order while renaming
      for (key, value) in examples {
        if key == oldKey {
          newExamples[newKey] = value
        } else {
          newExamples[key] = value
        }
      }

      mediaType.examples = newExamples
      requestBodyValue.content[contentType] = mediaType
      document[path: path][method: operation].requestBody = .value(requestBodyValue)
    }
  }

  private func updateSingleExample(_ contentType: String, example: OrderedJSONObject) {
    if case .value(var requestBodyValue) = document[path: path][method: operation].requestBody,
       var mediaType = requestBodyValue.content[contentType] {
      mediaType.example = example
      requestBodyValue.content[contentType] = mediaType
      document[path: path][method: operation].requestBody = .value(requestBodyValue)
    }
  }

  private func updateNamedExample(_ contentType: String, exampleKey: String, value: OrderedJSONObject) {
    if case .value(var requestBodyValue) = document[path: path][method: operation].requestBody,
       var mediaType = requestBodyValue.content[contentType],
       var examples = mediaType.examples {

      if let existingExample = examples[exampleKey] {
        switch existingExample {
        case .value(var example):
          example.value = value
          examples[exampleKey] = .value(example)
        case .reference:
          // Don't modify references
          break
        }
      }

      mediaType.examples = examples
      requestBodyValue.content[contentType] = mediaType
      document[path: path][method: operation].requestBody = .value(requestBodyValue)
    }
  }

  private func addExampleToMediaType(_ contentType: String) {
    if case .value(var requestBodyValue) = document[path: path][method: operation].requestBody,
       var mediaType = requestBodyValue.content[contentType] {

      if mediaType.example == nil && mediaType.examples == nil {
        // No examples yet, add a single example
        mediaType.example = [:]
      } else if mediaType.example != nil && mediaType.examples == nil {
        // Has single example, convert to examples
        let existingExample = mediaType.example
        mediaType.example = nil

        var examples = OrderedDictionary<String, OpenAPI.Referenceable<OpenAPI.Example>>()
        examples["Example 1"] = .value(OpenAPI.Example(value: existingExample))
        examples["Example 2"] = .value(OpenAPI.Example(value: [:]))
        mediaType.examples = examples
      } else if let existingExamples = mediaType.examples {
        // Already has examples, add another
        var examples = existingExamples
        let nextIndex = examples.count + 1
        examples["Example \(nextIndex)"] = .value(OpenAPI.Example(value: [:]))
        mediaType.examples = examples
      }

      requestBodyValue.content[contentType] = mediaType
      document[path: path][method: operation].requestBody = .value(requestBodyValue)
    }
  }

  private var requestBodyDescriptionBinding: Binding<String> {
    Binding(
      get: {
        if case .value(let requestBodyValue) = document[path: path][method: operation].requestBody {
          return requestBodyValue.description ?? ""
        }
        return ""
      },
      set: { newValue in
        if case .value(var requestBodyValue) = document[path: path][method: operation].requestBody {
          requestBodyValue.description = newValue.isEmpty ? nil : newValue
          document[path: path][method: operation].requestBody = .value(requestBodyValue)
        }
      }
    )
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text("Request Body Examples")
          .font(.headline)

        if isEditMode {
          Spacer()

          Button(action: {
            deleteRequestBody()
          }) {
            Label("Delete", systemImage: "trash")
              .foregroundColor(.red)
          }
          .buttonStyle(.plain)
        }
      }

      // Description section
      if requestBody.description != nil || isEditMode {
        if requestBody.description != nil {
          MarkdownTextView(markdown: requestBodyDescriptionBinding, editable: isEditMode)
            .font(.body)
            .foregroundColor(.secondary)
        } else if isEditMode {
          Button(action: addDescription) {
            Label("Add Description", systemImage: "plus.circle")
              .foregroundColor(.accentColor)
          }
          .buttonStyle(.plain)
        }
      }

      if requestBody.required == true {
        Text("Required")
          .font(.caption)
          .foregroundColor(.orange)
          .padding(.horizontal, 8)
          .padding(.vertical, 2)
          .background(Color.orange.opacity(0.2))
          .cornerRadius(4)
      }

      ForEach(Array(requestBody.content.keys.sorted()), id: \.self) { mediaTypeName in
        if let mediaType = requestBody.content[mediaTypeName] {
          VStack(alignment: .leading, spacing: 4) {
            HStack {
              if isEditMode {
                MediaTypeNameField(
                  mediaTypeName: mediaTypeName,
                  onRename: { newName in
                    renameContentType(from: mediaTypeName, to: newName)
                  }
                )

                Spacer()

                Button(action: {
                  deleteContentType(mediaTypeName)
                }) {
                  Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.caption)
                }
                .buttonStyle(.plain)
              } else {
                Text(mediaTypeName)
                  .font(.caption.monospaced())
                  .foregroundColor(.secondary)
              }
            }

            RequestBodyExampleContentView(
              mediaType: mediaType,
              document: document,
              contentType: mediaTypeName,
              onAddExample: {
                addExampleToMediaType(mediaTypeName)
              },
              onRenameExample: { oldKey, newKey in
                renameExample(in: mediaTypeName, from: oldKey, to: newKey)
              },
              onUpdateSingleExample: { example in
                updateSingleExample(mediaTypeName, example: example)
              },
              onUpdateNamedExample: { exampleKey, value in
                updateNamedExample(mediaTypeName, exampleKey: exampleKey, value: value)
              }
            )
          }
        }
      }

      // Add Content button in edit mode
      if isEditMode {
        Button(action: addContent) {
          Label("Add Content Type", systemImage: "plus.circle")
            .foregroundColor(.accentColor)
        }
        .buttonStyle(.plain)
        .disabled(getNextContentType() == nil)
      }
    }
  }
}

struct ExampleNameField: View {
  @State private var editingName: String
  let onRename: (String) -> Void

  init(exampleName: String, onRename: @escaping (String) -> Void) {
    self._editingName = State(initialValue: exampleName)
    self.onRename = onRename
  }

  var body: some View {
    TextField("Example Name", text: $editingName)
      .font(.caption.bold())
      .foregroundColor(.primary)
      .textFieldStyle(.plain)
      .onSubmit {
        onRename(editingName)
      }
  }
}

struct MediaTypeNameField: View {
  @State private var editingName: String
  let onRename: (String) -> Void

  init(mediaTypeName: String, onRename: @escaping (String) -> Void) {
    self._editingName = State(initialValue: mediaTypeName)
    self.onRename = onRename
  }

  var body: some View {
    TextField("Content Type", text: $editingName)
      .font(.caption.monospaced())
      .foregroundColor(.secondary)
      .textFieldStyle(.plain)
      .onSubmit {
        onRename(editingName)
      }
      .onChange(of: editingName) { _, newValue in
        // Only rename on submit to avoid issues with ForEach id
      }
  }
}

struct RequestBodyExampleContentView: View {
  let mediaType: OpenAPI.MediaType
  let document: OpenAPI.Document
  let contentType: String
  let onAddExample: () -> Void
  let onRenameExample: (String, String) -> Void
  let onUpdateSingleExample: (OrderedJSONObject) -> Void
  let onUpdateNamedExample: (String, OrderedJSONObject) -> Void

  @Environment(\.editMode) private var isEditMode

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 8) {
        // Add example button in edit mode
        if isEditMode {
          Button(action: onAddExample) {
            Label("Add Example", systemImage: "plus.circle")
              .foregroundColor(.accentColor)
              .font(.caption)
          }
          .buttonStyle(.plain)
          .padding(.vertical, 8)
          .padding(.horizontal, 12)
        }

        // Show single example if available
        if let example = mediaType.example {
          EditableJSONObjectView(json: Binding(
            get: { example },
            set: { newValue in
              onUpdateSingleExample(newValue)
            }
          ))
          .padding(12)
        }
        // Show named examples if available
        else if let examples = mediaType.examples, !examples.isEmpty {
          ForEach(Array(examples.keys.sorted()), id: \.self) { exampleKey in
            if let exampleRef = examples[exampleKey],
               let example = exampleRef.resolve(in: document),
               let value = example.value {
              VStack(alignment: .leading, spacing: 4) {
                if isEditMode {
                  ExampleNameField(
                    exampleName: exampleKey,
                    onRename: { newName in
                      onRenameExample(exampleKey, newName)
                    }
                  )
                } else if let summary = example.summary {
                  Text(summary)
                    .font(.caption.bold())
                    .foregroundColor(.primary)
                } else {
                  Text(exampleKey)
                    .font(.caption.bold())
                    .foregroundColor(.primary)
                }
                EditableJSONObjectView(json: Binding(
                  get: { value },
                  set: { newValue in
                    onUpdateNamedExample(exampleKey, newValue)
                  }
                ))
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
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(.secondary.opacity(0.1))
    )
  }
}
