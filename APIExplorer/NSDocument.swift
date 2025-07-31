//
//  NSDocument.swift
//  Jotter
//
//  Created by Ben Davis on 08/05/2025.
//

import AppKit

///
/// Swizzles out the displayName of `NSDocument` instances.
///
/// This is used as we use the SwiftUI `DocumentGroup`, and therefore do not create instances of `NSDocument`
/// directly. The `displayName` property is used in Save dialogs and other places, so returning the computed document
/// title allows us to set a default file name.
extension NSDocument {
  static func performSwizzles() {
    _ = swizzleDisplayName
  }

  static var swizzleDisplayName: Bool = {
    let originalSelector = #selector(getter: NSDocument.displayName)
    let swizzledSelector = #selector(NSDocument.swizzled_displayName)

    if let originalMethod = class_getInstanceMethod(NSDocument.self, originalSelector),
       let swizzledMethod = class_getInstanceMethod(NSDocument.self, swizzledSelector) {

      // Swap the implementations
      method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    return true
  }()

  @objc func swizzled_displayName() -> String {
    let result = self.swizzled_displayName()
    return windowForSheet?.openAPIFileName?() ?? result
  }
}

nonisolated(unsafe) private var WindowAssociatedObjectHandle: UInt8 = 0
extension NSWindow {
  fileprivate var openAPIFileName: (() -> String?)? {
    get {
      return objc_getAssociatedObject(
        self,
        &WindowAssociatedObjectHandle
      ) as? (() -> String?)
    }
    set {
      objc_setAssociatedObject(
        self,
        &WindowAssociatedObjectHandle,
        newValue,
        objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
    }
  }

  func setOpenAPIFileName(_ fileNameFactory: @escaping @autoclosure () -> String?) {
    openAPIFileName = fileNameFactory
  }
}
