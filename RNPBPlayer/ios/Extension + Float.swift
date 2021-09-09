import Foundation
extension Float {
  var clean: Int {
    guard let cleanNumber = Int(String(format: "%.0f", self)) else { return Int(self) }
    return cleanNumber
  }
}
