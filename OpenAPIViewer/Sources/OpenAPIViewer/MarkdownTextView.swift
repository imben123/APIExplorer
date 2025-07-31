//
//  MarkdownTextView.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 31/07/2025.
//

import SwiftUI
import RichTextView

struct MarkdownTextView: View {

  @Binding var markdown: String
  @Environment(\.font) private var font
  let editable: Bool

  init(markdown: String) {
    self._markdown = .constant(markdown.trimmingWhitespace())
    self.editable = false
  }

  init(markdown: Binding<String>, editable: Bool = false) {
    self._markdown = markdown
    self.editable = editable
  }

  var containsHeading: Bool {
    try! markdown.matches("(^|\\n)#+($|\n| )")
  }

  var body: some View {
    RichTextEditor(markdown: $markdown, fixedHeight: true)
      .richTextOverscroll(0)
      .richTextEditable(editable)
      .frame(maxWidth: 600)
      .padding(.trailing, containsHeading ? -(fontSize(from: font) + 4) : -28)
      .offset(x: containsHeading ? 0 : -(fontSize(from: font) + 6), y: -10)
  }

  func fontSize(from font: Font?) -> CGFloat {
    switch font {
    case .largeTitle:
      return 34
    case .title:
      return 28
    case .title2:
      return 22
    case .title3:
      return 20
    case .headline:
      return 15
    case .body:
      return 14
    case .callout:
      return 13
    case .subheadline:
      return 13
    case .footnote:
      return 12
    case .caption:
      return 11
    case .caption2:
      return 10
    default:
      return 14
    }
  }
}
