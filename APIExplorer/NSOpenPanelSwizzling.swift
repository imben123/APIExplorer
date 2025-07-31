//
//  NSOpenPanelSwizzling.swift
//  APIExplorer
//
//  Created by Ben Davis on 29/07/2025.
//

import AppKit
import ObjectiveC

@objc class NSOpenPanelSwizzler: NSObject {

  override init() {
    super.init()
    swizzlePropertySetter()
  }

  private func swizzlePropertySetter() {
    // Swizzle the canChooseDirectories setter to prevent DocumentGroup from disabling folder selection
    guard let setter = class_getInstanceMethod(NSOpenPanel.self, #selector(setter: NSOpenPanel.canChooseDirectories)),
          let swizzledSetter = class_getInstanceMethod(NSOpenPanel.self, #selector(NSOpenPanel.swizzled_setCanChooseDirectories(_:))) else {
      return
    }
    
    method_exchangeImplementations(setter, swizzledSetter)
  }
}

extension NSOpenPanel {

  @objc func swizzled_setCanChooseDirectories(_ value: Bool) {
    // Always force folder selection to be enabled, ignore the original value
    swizzled_setCanChooseDirectories(true)
  }

  static func enableFolderSelection() {
    _ = NSOpenPanelSwizzler()
  }
}
