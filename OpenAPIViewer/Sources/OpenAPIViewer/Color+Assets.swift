import SwiftUI
import AppToolbox

extension Color {
  static let codeConstant = Color("CodeConstant", bundle: .module)
  static let codeNumber = Color("CodeNumberColor", bundle: .module)
  static let codeGreen = Color("CodeGreen", bundle: .module)
  static let codeRed = Color("CodeRed", bundle: .module)
  static let code = Color("CodeColor", bundle: .module)
}

extension CrossPlatformColor {
  static let codeConstant = CrossPlatformColor(named: "CodeConstant", bundle: .module)
  static let codeNumber = CrossPlatformColor(named: "CodeNumberColor", bundle: .module)
  static let codeGreen = CrossPlatformColor(named: "CodeGreen", bundle: .module)
  static let codeRed = CrossPlatformColor(named: "CodeRed", bundle: .module)
  static let code = CrossPlatformColor(named: "CodeColor", bundle: .module)
}
