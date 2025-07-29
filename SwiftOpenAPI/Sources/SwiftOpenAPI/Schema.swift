//
//  Schema.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftToolbox

public extension OpenAPI {
  /// The Schema Object allows the definition of input and output data types.
  indirect enum Schema: Model {
    case schema(SchemaObject)
    case reference(String)
    
    public var schemaObject: SchemaObject? {
      switch self {
      case .schema(let obj):
        return obj
      case .reference:
        return nil
      }
    }
    
    public var reference: String? {
      switch self {
      case .schema:
        return nil
      case .reference(let ref):
        return ref
      }
    }
    
    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      if let refContainer = try? decoder.container(keyedBy: CodingKeys.self),
         let ref = try? refContainer.decode(String.self, forKey: .ref) {
        self = .reference(ref)
      } else {
        let schemaObj = try container.decode(SchemaObject.self)
        self = .schema(schemaObj)
      }
    }
    
    public func encode(to encoder: Encoder) throws {
      switch self {
      case .schema(let obj):
        try obj.encode(to: encoder)
      case .reference(let ref):
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ref, forKey: .ref)
      }
    }
    
    private enum CodingKeys: String, CodingKey {
      case ref = "$ref"
    }
  }
  
  /// The actual schema object with all properties.
  struct SchemaObject: Model {
    // Core JSON Schema properties
    public let title: String?
    public let multipleOf: Double?
    public let maximum: Double?
    public let exclusiveMaximum: Bool?
    public let minimum: Double?
    public let exclusiveMinimum: Bool?
    public let maxLength: Int?
    public let minLength: Int?
    public let pattern: String?
    public let maxItems: Int?
    public let minItems: Int?
    public let uniqueItems: Bool?
    public let maxProperties: Int?
    public let minProperties: Int?
    public let required: [String]?
    public let `enum`: [JSONObject]?
    
    // Schema composition
    public let allOf: [Schema]?
    public let oneOf: [Schema]?
    public let anyOf: [Schema]?
    public let not: Schema?
    
    // Type-specific properties
    public let type: SchemaType?
    public let format: String?
    public let items: Schema?
    public let properties: [String: Schema]?
    public let additionalProperties: AdditionalProperties?
    public let description: String?
    public let `default`: JSONObject?
    
    // OpenAPI-specific properties
    public let nullable: Bool?
    public let discriminator: Discriminator?
    public let readOnly: Bool?
    public let writeOnly: Bool?
    public let example: JSONObject?
    public let externalDocs: ExternalDocumentation?
    public let deprecated: Bool?
    public let xml: XML?

    private enum CodingKeys: String, CodingKey {
      case title, multipleOf, maximum, exclusiveMaximum, minimum, exclusiveMinimum
      case maxLength, minLength, pattern, maxItems, minItems, uniqueItems
      case maxProperties, minProperties, required
      case `enum` = "enum"
      case allOf, oneOf, anyOf, not, type, format, items, properties, additionalProperties
      case description
      case `default` = "default"
      case nullable, discriminator, readOnly, writeOnly, example, externalDocs, deprecated, xml
    }

    public init(
      title: String? = nil,
      multipleOf: Double? = nil,
      maximum: Double? = nil,
      exclusiveMaximum: Bool? = nil,
      minimum: Double? = nil,
      exclusiveMinimum: Bool? = nil,
      maxLength: Int? = nil,
      minLength: Int? = nil,
      pattern: String? = nil,
      maxItems: Int? = nil,
      minItems: Int? = nil,
      uniqueItems: Bool? = nil,
      maxProperties: Int? = nil,
      minProperties: Int? = nil,
      required: [String]? = nil,
      enum: [JSONObject]? = nil,
      allOf: [Schema]? = nil,
      oneOf: [Schema]? = nil,
      anyOf: [Schema]? = nil,
      not: Schema? = nil,
      type: SchemaType? = nil,
      format: String? = nil,
      items: Schema? = nil,
      properties: [String: Schema]? = nil,
      additionalProperties: AdditionalProperties? = nil,
      description: String? = nil,
      default: JSONObject? = nil,
      nullable: Bool? = nil,
      discriminator: Discriminator? = nil,
      readOnly: Bool? = nil,
      writeOnly: Bool? = nil,
      example: JSONObject? = nil,
      externalDocs: ExternalDocumentation? = nil,
      deprecated: Bool? = nil,
      xml: XML? = nil
    ) {
      self.title = title
      self.multipleOf = multipleOf
      self.maximum = maximum
      self.exclusiveMaximum = exclusiveMaximum
      self.minimum = minimum
      self.exclusiveMinimum = exclusiveMinimum
      self.maxLength = maxLength
      self.minLength = minLength
      self.pattern = pattern
      self.maxItems = maxItems
      self.minItems = minItems
      self.uniqueItems = uniqueItems
      self.maxProperties = maxProperties
      self.minProperties = minProperties
      self.required = required
      self.enum = `enum`
      self.allOf = allOf
      self.oneOf = oneOf
      self.anyOf = anyOf
      self.not = not
      self.type = type
      self.format = format
      self.items = items
      self.properties = properties
      self.additionalProperties = additionalProperties
      self.description = description
      self.default = `default`
      self.nullable = nullable
      self.discriminator = discriminator
      self.readOnly = readOnly
      self.writeOnly = writeOnly
      self.example = example
      self.externalDocs = externalDocs
      self.deprecated = deprecated
      self.xml = xml
    }
  }
  
  /// JSON Schema primitive types.
  enum SchemaType: String, Model {
    case null
    case boolean
    case object
    case array
    case number
    case string
    case integer
  }
  
  /// Represents additional properties in a schema.
  indirect enum AdditionalProperties: Model {
    case boolean(Bool)
    case schema(Schema)
    
    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      if let boolValue = try? container.decode(Bool.self) {
        self = .boolean(boolValue)
      } else {
        let schemaValue = try container.decode(Schema.self)
        self = .schema(schemaValue)
      }
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      switch self {
      case .boolean(let bool):
        try container.encode(bool)
      case .schema(let schema):
        try container.encode(schema)
      }
    }
  }
}
