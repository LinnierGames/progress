import UIKit

extension UIAlertController {
  func insertTextField(_ config: ((UITextField) -> Void)? = nil) -> UITextField {
    var tf: UITextField! = nil
    let _: Void = self.addTextField { textField in
      config?(textField)
      tf = textField
    }

    return tf
  }
}

extension String {
  func useIfEmpty(_ string: String) -> String {
    guard self.isEmpty == false else { return string }
    return self
  }
}

extension Optional where Wrapped == String {
  func useIfEmptyOrNil(_ string: String) -> String {
    guard let self = self else { return string }
    return self.useIfEmpty(string)
  }
}
