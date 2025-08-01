//
//  EditModeEnvironment.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 01/08/2025.
//

import SwiftUI

struct EditModeKey: EnvironmentKey {
  static let defaultValue: Bool = false
}

extension EnvironmentValues {
  var editMode: Bool {
    get { self[EditModeKey.self] }
    set { self[EditModeKey.self] = newValue }
  }
}