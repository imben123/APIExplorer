//
//  YAMLEncoder.swift
//  SwiftOpenAPI
//
//  Created by Ben Davis on 06/08/2025.
//

import Foundation
import Yams

nonisolated extension YAMLEncoder {
  static var `default`: YAMLEncoder {
    let result = YAMLEncoder()
    result.orderedDictionaryCodingStrategy = .keyedContainer
    result.options = .init(
      sequenceStyle: .any,
      mappingStyle: .any,
      newLineScalarStyle: Node.Scalar.Style.folded
    )
    return result
  }
}
