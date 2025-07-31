//
//  Yams+OrderedDictionaryCodingStrategy.swift
//  SwiftOpenAPI
//
//  Created by Ben Davis on 31/07/2025.
//

import Foundation
import Yams
import Collections

extension YAMLEncoder {
  /// Strategy for encoding OrderedDictionary instances
  public var orderedDictionaryCodingStrategy: OrderedDictionaryCodingStrategy {
    get {
      userInfo[.orderedDictionaryCodingStrategy] as? OrderedDictionaryCodingStrategy ?? .unkeyedContainer
    }
    set {
      userInfo[.orderedDictionaryCodingStrategy] = newValue
    }
  }
}

extension YAMLDecoder {
  /// Strategy for decoding OrderedDictionary instances
  public var orderedDictionaryCodingStrategy: OrderedDictionaryCodingStrategy {
    get {
      userInfo[.orderedDictionaryCodingStrategy] as? OrderedDictionaryCodingStrategy ?? .unkeyedContainer
    }
    set {
      userInfo[.orderedDictionaryCodingStrategy] = newValue
    }
  }
}
