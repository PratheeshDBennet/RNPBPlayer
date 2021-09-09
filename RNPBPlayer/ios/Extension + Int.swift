import Foundation
extension Int {
  var time: (Int, Int, Int) {
    return (self / 3600, (self % 3600) / 60, (self % 3600) % 60)
  }
}
