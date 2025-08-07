//
//  HTTPMethod.swift
//  SwiftOpenAPI
//
//  Created by Ben Davis on 30/07/2025.
//

import Foundation
import SwiftToolbox

public enum HTTPMethod: String, CaseIterable, Model {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case delete = "DELETE"
  case patch = "PATCH"
  case head = "HEAD"
  case options = "OPTIONS"
  case trace = "TRACE"
}
