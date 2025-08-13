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
  var requestBody: OpenAPI.RequestBody
  @Binding var document: OpenAPI.Document
  let path: String
  let operation: HTTPMethod

  @Environment(\.editMode) private var isEditMode

  private var requestBodyBinding: Binding<OpenAPI.RequestBody> {
    $document[requestBody: OperationReference(path: path, method: operation)]
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
          MarkdownTextView(markdown: $document[requestBody: OperationReference(path: path, method: operation)].description.defaultingToEmptyString, editable: isEditMode)
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

      // Required checkbox in edit mode
      if isEditMode {
        HStack {
          Toggle(isOn: Binding(
            get: {
              if case .value(let requestBodyValue) = document[path: path][method: operation].requestBody {
                return requestBodyValue.required == true
              }
              return false
            },
            set: { newValue in
              if case .value(var requestBodyValue) = document[path: path][method: operation].requestBody {
                requestBodyValue.required = newValue ? true : nil
                document[path: path][method: operation].requestBody = .value(requestBodyValue)
              }
            }
          )) {
            Text("Required")
              .font(.caption)
          }
          .toggleStyle(.checkbox)
        }
      } else if requestBody.required == true {
        Text("Required")
          .font(.caption)
          .foregroundColor(.orange)
          .padding(.horizontal, 8)
          .padding(.vertical, 2)
          .background(Color.orange.opacity(0.2))
          .cornerRadius(4)
      }

      ForEach(requestBody.content.keys.sorted(), id: \.self) { mediaTypeName in
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
            mediaType: requestBodyBinding.content[mediaTypeName],
            document: document,
            contentType: mediaTypeName
          )
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

  private func deleteRequestBody() {
    document[path: path][method: operation].requestBody = nil
  }

  private func addDescription() {
    let ref = OperationReference(path: path, method: operation)
    document[requestBody: ref].description = "Request body description"
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
    let ref = OperationReference(path: path, method: operation)
    document[requestBody: ref].content[contentType] = OpenAPI.MediaType()
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
    document[requestBody: OperationReference(path: path, method: operation)].content.removeValue(forKey: contentType)
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
  @Binding var mediaTypeOptional: OpenAPI.MediaType?
  let document: OpenAPI.Document
  let contentType: String

  @Environment(\.editMode) private var isEditMode

  init(mediaType: Binding<OpenAPI.MediaType?>,
       document: OpenAPI.Document,
       contentType: String) {
    self._mediaTypeOptional = mediaType
    self.document = document
    self.contentType = contentType
  }

  private var mediaType: OpenAPI.MediaType {
    get { mediaTypeOptional ?? .init() }
    nonmutating set { mediaTypeOptional = newValue }
  }

  private var examples: OrderedDictionary<String, OpenAPI.Referenceable<OpenAPI.Example>> {
    get {
      if let example = mediaType.example {
        return ["": .value(.init(
          summary: nil,
          description: nil,
          value: example,
          externalValue: nil
        ))]
      } else if let examples = mediaType.examples {
        return examples
      } else {
        return [:]
      }
    }
    nonmutating set {
      if newValue.isEmpty {
        // If no examples left, set to nil
        mediaType.example = nil
        mediaType.examples = nil
      } else if newValue.count == 1,
                let remainingKey = newValue.keys.first,
                remainingKey.isEmpty,
                let example = newValue.values.first?.resolve(in: document),
                example.description == nil,
                example.summary == nil,
                example.externalValue == nil,
                let value = example.value {
        // If only one example remains and its key is empty string, convert to single example
        mediaType.examples = nil
        mediaType.example = value
      } else {
        mediaType.example = nil
        mediaType.examples = newValue
      }
    }
  }

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
        if !examples.isEmpty {
          ForEach(Array(examples.keys.sorted()), id: \.self) { exampleKey in
            if let exampleRef = examples[exampleKey],
               let example = exampleRef.resolve(in: document),
               let value = example.value {
              VStack(alignment: .leading, spacing: 4) {
                HStack {
                  if isEditMode {
                    ExampleNameField(
                      exampleName: exampleKey,
                      onRename: { newName in
                        renameExample(from: exampleKey, to: newName)
                      }
                    )
                    
                    Spacer()
                    
                    Button(action: {
                      deleteExample(exampleKey)
                    }) {
                      Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.caption)
                    }
                    .buttonStyle(.plain)
                  } else if let summary = example.summary {
                    Text(summary)
                      .font(.caption.bold())
                      .foregroundColor(.primary)
                  } else if exampleKey != "" {
                    Text(exampleKey)
                      .font(.caption.bold())
                      .foregroundColor(.primary)
                  }
                }
                EditableJSONValueView(json: Binding(
                  get: { value },
                  set: { newValue in
                    updateValue(for: exampleKey, value: newValue)
                  }
                ))
              }
              .padding(12)
            }
          }
        } else {
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

  private func onAddExample() {
    if mediaType.example == nil && mediaType.examples == nil {
      // No examples yet, add a single example
      mediaType.example = .object([:])
    } else if mediaType.example != nil && mediaType.examples == nil {
      // Has single example, convert to examples
      let existingExample = mediaType.example
      mediaType.example = nil

      var examples = OrderedDictionary<String, OpenAPI.Referenceable<OpenAPI.Example>>()
      examples["Example 1"] = .value(OpenAPI.Example(value: existingExample))
      examples["Example 2"] = .value(OpenAPI.Example(value: .object([:])))
      mediaType.examples = examples
    } else if let existingExamples = mediaType.examples {
      // Already has examples, add another
      var examples = existingExamples
      let nextIndex = examples.count + 1
      examples["Example \(nextIndex)"] = .value(OpenAPI.Example(value: .object([:])))
      mediaType.examples = examples
    }
  }

  private func renameExample(from oldKey: String, to newKey: String) {
    guard oldKey != newKey else { return }

    var newExamples = OrderedDictionary<String, OpenAPI.Referenceable<OpenAPI.Example>>()

    // Preserve order while renaming
    for (key, value) in examples {
      if key == oldKey {
        newExamples[newKey] = value
      } else {
        newExamples[key] = value
      }
    }

    examples = newExamples
  }

  private func deleteExample(_ key: String) {
    examples.removeValue(forKey: key)
  }

  private func updateValue(for key: String, value: OrderedJSONValue) {
    guard var example = examples[key]?.resolve(in: document) else {
      return
    }
    example.value = value
    examples[key] = .value(example)
  }
}
