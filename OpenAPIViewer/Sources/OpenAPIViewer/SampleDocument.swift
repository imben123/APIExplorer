//
//  SampleDocument.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 30/07/2025.
//

import SwiftOpenAPI

let sampleDocument: OpenAPI.Document = {
  let getUserOperation = OpenAPI.Operation(
    summary: "Get user by ID",
    responses: OpenAPI.Responses(responses: [
      "200": .reference("#/components/responses/UserResponse")
    ])
  )
  
  let createUserOperation = OpenAPI.Operation(
    summary: "Create new user",
    requestBody: .reference("#/components/requestBodies/CreateUserRequest"),
    responses: OpenAPI.Responses(responses: [
      "201": .reference("#/components/responses/UserResponse")
    ])
  )
  
  let healthCheckOperation = OpenAPI.Operation(
    summary: "Health check",
    responses: OpenAPI.Responses(responses: [
      "200": .reference("#/components/responses/HealthResponse")
    ])
  )
  
  let userPathItem = OpenAPI.PathItem(
    get: getUserOperation
  )
  
  let usersPathItem = OpenAPI.PathItem(
    post: createUserOperation
  )
  
  let healthPathItem = OpenAPI.PathItem(
    get: healthCheckOperation
  )
  
  return OpenAPI.Document(
    openapi: "3.0.0",
    info: OpenAPI.Info(title: "Sample API", version: "1.0.0"),
    paths: [
      "/users/{id}": .value(userPathItem),
      "/users": .value(usersPathItem),
      "/health": .value(healthPathItem)
    ]
  )
}()
