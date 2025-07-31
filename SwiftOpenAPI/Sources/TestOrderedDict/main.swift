import Foundation
import Yams
import SwiftToolbox
import Collections
import SwiftOpenAPI

let yamlString = """
key1: "value1"
key2: "value2"
key3: "value3"
"""

print("Testing YAML decoding with OrderedDictionary...")
print("YAML content:")
print(yamlString)
print("\n" + String(repeating: "=", count: 50))

do {
    // Test 1: Decode regular dictionary
    print("\nTest 1: Decoding regular [String: String]...")
    let decoder = YAMLDecoder()
    decoder.orderedDictionaryCodingStrategy = .keyedContainer
    let regularResult = try decoder.decode([String: String].self, from: yamlString)
    print("✅ Success: \(regularResult)")
    
} catch {
    print("❌ Regular dictionary decode failed: \(error)")
}

// Test 2: Check if OrderedDictionary conforms to Codable
print("\nTest 2: Checking OrderedDictionary Codable conformance...")
let dict = OrderedDictionary<String, String>()
print("OrderedDictionary type: \(type(of: dict))")
print("Does OrderedDictionary conform to Decodable? \(dict is Decodable)")
print("Does OrderedDictionary conform to Encodable? \(dict is Encodable)")
print("Does OrderedDictionary conform to Codable? \(dict is Codable)")

// Test 3: Try to use OrderedJSONValue
print("\nTest 3: Testing OrderedJSONValue...")
do {
    let decoder = YAMLDecoder()
    decoder.orderedDictionaryCodingStrategy = .keyedContainer
    let jsonValueResult = try decoder.decode(OrderedJSONValue.self, from: yamlString)
    print("✅ OrderedJSONValue Success: \(jsonValueResult)")
} catch {
    print("❌ OrderedJSONValue decode failed: \(error)")
    if let decodingError = error as? DecodingError {
        switch decodingError {
        case .typeMismatch(let type, let context):
            print("  Type mismatch: expected \(type)")
            print("  Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
            print("  Debug description: \(context.debugDescription)")
        default:
            print("  Other decoding error: \(decodingError)")
        }
    }
}