//
//  ComponentFileSerializable.swift
//  SwiftOpenAPI
//
//  Created by Ben Davis on 05/08/2025.
//

protocol ComponentFileSerializable {
  /// SHA256 hash of the original serialized data for change detection.
  /// This property is excluded from Codable to prevent it from being serialized.
  var originalDataHash: String? { get set }
}
