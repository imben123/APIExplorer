//
//  HTTPMethod.swift
//  SwiftOpenAPI
//
//  Created by Ben Davis on 30/07/2025.
//

import Foundation

public enum HTTPMethod: String, CaseIterable, Codable {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case delete = "DELETE"
  case patch = "PATCH"
  case head = "HEAD"
  case options = "OPTIONS"
  case trace = "TRACE"
  
  public var rawValue: String {
    switch self {
    case .get: return "GET"
    case .post: return "POST"
    case .put: return "PUT"
    case .delete: return "DELETE"
    case .patch: return "PATCH"
    case .head: return "HEAD"
    case .options: return "OPTIONS"
    case .trace: return "TRACE"
    }
  }
}