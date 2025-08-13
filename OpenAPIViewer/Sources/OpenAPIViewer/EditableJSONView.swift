//
//  EditableJSONView.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 06/08/2025.
//

import SwiftUI
import SwiftToolbox
import RichTextView
import AppToolbox

struct EditableJSONValueView: View {
  @Binding var json: OrderedJSONValue
  @State private var isEditing = false
  @State private var jsonText = ""
  @State private var hasError = false
  
  var body: some View {
    if isEditing {
      ZStack(alignment: .topTrailing) {
        CodeEditor(string: $jsonText, fixedHeight: true)
          .richTextOverscroll(0)
          .richTextCodeHighlightingLightTheme(LightTheme())
          .font(.system(.body, design: .monospaced))
          .border(hasError ? Color.red : Color.gray.opacity(0.3), width: hasError ? 2 : 1)
          .autocorrectionDisabled(true)
          .onChange(of: jsonText) { _, _ in
            hasError = false
          }

        Button("Done") {
          saveJSON()
        }
        .buttonStyle(.borderedProminent)
      }
    } else {
      JSONView(json: json)
        .onTapGesture(count: 2) {
          startEditing()
        }
    }
  }
  
  private func startEditing() {
    jsonText = prettyPrintJSON(json)
    isEditing = true
    hasError = false
  }
  
  private func saveJSON() {
    guard let data = jsonText.data(using: .utf8) else {
      hasError = true
      return
    }
    
    do {
      let decoder = OrderedJSONDecoder()
      let parsed = try decoder.decode(OrderedJSONValue.self, from: data)
      json = parsed
      isEditing = false
      hasError = false
    } catch {
      hasError = true
    }
  }
  
  private func prettyPrintJSON(_ value: OrderedJSONValue) -> String {
    do {
      let encoder = OrderedJSONEncoder()
      encoder.outputFormatting = [.prettyPrinted]
      let data = try encoder.encode(value)
      return String(data: data, encoding: .utf8) ?? "{}"
    } catch {
      return "{}"
    }
  }
}

struct LightTheme: CodeHighlightingTheme {
  let keywords = HighlightingThemeItem(
    color: CrossPlatformColor(hexString: "9B2393"),
    fontTraits: [.traitBold, .traitMonoSpace],
    semiBold: true
  )
  let strings = HighlightingThemeItem(color: .codeConstant)
  let numbers = HighlightingThemeItem(color: .codeNumber)
  let constants = HighlightingThemeItem(color: .codeConstant)
  let comments = HighlightingThemeItem(colorHex: "5D6C79")
  let builtinFunctions = HighlightingThemeItem(colorHex: "6C36A9")
  let macroFunctions = HighlightingThemeItem(colorHex: "643820")
  let functionsAndVariables = HighlightingThemeItem(colorHex: "326D74")
  let attributes = HighlightingThemeItem(colorHex: "FFA800")
  let typesAndModules = HighlightingThemeItem(colorHex: "3900A0")
}
