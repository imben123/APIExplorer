//
//  Box.swift
//  SwiftOpenAPI
//
//  Created by Ben Davis on 13/08/2025.
//

import Foundation

public final class Box<T>: @unchecked Sendable {
  public var value: T

  public init(_ value: T) {
    self.value = value
  }
}

extension Box: Equatable where T: Equatable {
  public static func == (lhs: Box<T>, rhs: Box<T>) -> Bool {
    return lhs.value == rhs.value
  }
}

extension Box: Hashable where T: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(value)
  }
}
