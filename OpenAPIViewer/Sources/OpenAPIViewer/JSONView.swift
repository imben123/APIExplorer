//
//  JSONView.swift
//  APIExplorer
//
//  Created by Ben Davis on 03/04/2024.
//

import SwiftUI
import SwiftToolbox

struct JSONView: View {
  let json: OrderedJSONValue
  fileprivate let isNested: Bool

  var body: some View {
    switch json {
    case .string(let string):
      JSONStringView(string: string)
    case .int(let int):
      JSONIntegerView(integer: int)
    case .double(let double):
      JSONDoubleView(double: double)
    case .bool(let bool):
      JSONBoolView(bool: bool)
    case .object(let orderedDictionary):
      JSONObjectView(object: orderedDictionary,
                     isNested: isNested)
    case .array(let array):
      JSONArrayView(array: array, 
                    isNested: isNested)
    case .null:
      JSONNullView()
    }
  }
}

private extension JSONView {
  static let tabSpace: CGFloat = 16
}

extension JSONView {
  init(json: OrderedJSONValue) {
    self.init(json: json, isNested: false)
  }
}

private struct JSONStringView: View {
  let string: String
  var body: some View {
    JSONText("\"" + string + "\"")
      .foregroundColor(.codeConstant)
  }
}

private struct JSONIntegerView: View {
  let integer: Int
  var body: some View {
    JSONText("\(integer)")
      .foregroundStyle(Color.codeNumber)
  }
}

private struct JSONDoubleView: View {
  let double: Double
  var body: some View {
    JSONText("\(double)".removingTrailingCharacters(in: CharacterSet(charactersIn: "0")))
      .foregroundStyle(Color.codeNumber)
  }
}

private struct JSONBoolView: View {
  let bool: Bool
  var body: some View {
    JSONText(bool ? "true" : "false")
      .foregroundStyle(bool ? Color.codeGreen : Color.codeRed)
  }
}

private struct JSONNullView: View {
  var body: some View {
    JSONText("null")
      .foregroundColor(.code)
  }
}

private struct JSONArrayView: View {
  let array: [OrderedJSONValue]
  let isNested: Bool
  var body: some View {
    VStack(alignment: .leading) {
      if !isNested {
        JSONText("[")
      }
      ForEach(Array(array.indices), id: \.self) { index in
        VStack(alignment: .leading) {
          array[index].openingSymbol
          HStack(alignment: .lastTextBaseline ,spacing: 0) {
            JSONView(json: array[index], isNested: true)
            if array[index].isInlineable && index < array.count - 1 {
              JSONText(",")
            }
          }
        }
        .padding(.leading, JSONView.tabSpace)
      }
      JSONText("]" + (isNested ? "," : ""))
    }
  }
}

private struct JSONObjectView: View {
  let object: OrderedJSONObject
  let isNested: Bool
  var body: some View {
    VStack(alignment: .leading) {
      if !isNested {
        JSONText("{")
      }
      ForEach(Array(object.keys.enumerated()), id: \.element) { index, key in
        let nestedValue = object[key]!
        VStack(alignment: .leading) {
          HStack(alignment: .firstTextBaseline) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
              JSONText("\"\(key)\"")
                .foregroundColor(.codeConstant)
              JSONText(":")
            }
            if nestedValue.isInlineable {
              HStack(spacing: 0) {
                JSONView(json: nestedValue, isNested: true)
                if index < object.keys.count - 1 {
                  JSONText(",")
                }
              }
            } else {
              nestedValue.openingSymbol
            }
          }
          if !nestedValue.isInlineable {
            JSONView(json: nestedValue, isNested: true)
          }
        }
        .padding(.leading, JSONView.tabSpace)
      }
      JSONText("}" + (isNested ? "," : ""))
    }
  }
}

struct JSONText: View {
  let text: String
  
  init(_ text: String) {
    self.text = text
  }
  
  var body: some View {
    Text(text)
      .monospaced()
      .lineLimit(1)
      .truncationMode(.middle)
  }
}

private extension OrderedJSONValue {

  @ViewBuilder
  var openingSymbol: some View {
    switch self {
    case .object:
      JSONText("{")
    case .array:
      JSONText("[")
    default:
      EmptyView()
    }
  }

  var isInlineable: Bool {
    switch self {
    case .object, .array:
      return false
    default:
      return true
    }
  }
}

private extension String {
  func removingTrailingCharacters(in characters: CharacterSet) -> String {
    guard let index = lastIndex(where: {
      !CharacterSet(charactersIn: String($0)).isSubset(of: characters)
    }) else {
      return ""
    }
    return String(self[...index])
  }
}

#Preview {
  JSONView(json: .object([
    "Foo": .string("Bar"),
    "nestedObject": .object([
      "integer": .int(123),
      "decimal": .double(123.456)
    ]),
    "array": .array([
      .bool(true),
      .bool(false),
      .null,
      .object([
        "Hello": .string("world")
      ])
    ])
  ]))
}
