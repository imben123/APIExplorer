//
//  OperationReference.swift
//  SwiftOpenAPI
//
//  Created by Ben Davis on 07/08/2025.
//

import Foundation
import SwiftToolbox

public struct OperationReference: Model {
  public let path: String
  public let method: HTTPMethod

  public init(path: String, method: HTTPMethod) {
    self.path = path
    self.method = method
  }
}
