import UIKit

extension UIAlertController {

  // MARK: Categories

  enum CategoryAction {
    case update(title: String)
    case delete
  }

  static func createCategory(completion: @escaping (String) -> Void) -> UIAlertController {
    let (alert, titleTf) = self.categoryAlert(alertTitle: "New Category", title: "")

    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
      completion(titleTf.text ?? "")
    })

    return alert
  }

  static func modifyCategory(title: String, completion: @escaping (CategoryAction) -> Void) -> UIAlertController {
    let (alert, titleTf) = self.categoryAlert(alertTitle: "New Category", title: title)

    alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
      let titleValue = titleTf.text.useIfEmptyOrNil("Untitle")
      completion(.update(title: titleValue))
    })
    alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
      completion(.delete)
    })
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

    return alert
  }

  private static func categoryAlert(
    alertTitle: String,
    title: String
  ) -> (alert: UIAlertController, title: UITextField) {
    let alert = UIAlertController(
      title: alertTitle,
      message: nil,
      preferredStyle: .alert
    )
    let eventTitleTextField = alert.insertTextField { textField in
      textField.text = title
      textField.autocorrectionType = .yes
      textField.autocapitalizationType = .sentences
      textField.placeholder = "Category title"
    }

    return (alert, eventTitleTextField)
  }

  // MARK: Rewards

  enum RewardAction {
    case update(title: String, points: Int)
    case delete
  }

  static func createReward(completion: @escaping ((title: String, points: Int)) -> Void) -> UIAlertController {
    let (alert, titleTf, pointsTf) = self.rewardAlert(alertTitle: "New Reward", title: "", points: 0)

    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
      let titleValue = titleTf.text ?? ""
      let pointsValue = Int(pointsTf.text ?? "") ?? 0
      completion((titleValue, pointsValue))
    })

    return alert
  }

  static func modifyReward(
    title: String, points: Int, completion: @escaping (RewardAction) -> Void) -> UIAlertController {
    let (alert, titleTf, pointsTf) = self.eventAlert(alertTitle: "Modify Reward", title: title, points: points)

    alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
      let titleValue = titleTf.text ?? ""
      let pointsValue = Int(pointsTf.text ?? "") ?? 0
      completion(.update(title: titleValue, points: pointsValue))
    })
    alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
      completion(.delete)
    })
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

    return alert
  }

  private static func rewardAlert(
    alertTitle: String,
    title: String,
    points: Int
  ) -> (alert: UIAlertController, title: UITextField, points: UITextField) {
    let alert = UIAlertController(
      title: alertTitle,
      message: "enter a title for the reward",
      preferredStyle: .alert
    )
    let eventTitleTextField = alert.insertTextField { textField in
    textField.text = title
      textField.autocorrectionType = .yes
      textField.autocapitalizationType = .sentences
      textField.placeholder = "Reward title"
    }
    let pointValueTextField = alert.insertTextField { textField in
      textField.text = String(points)
      textField.placeholder = "Points"
      textField.keyboardType = .numberPad
    }

    return (alert, eventTitleTextField, pointValueTextField)
  }

  // MARK: Events

  enum EventAction {
    case update(title: String, points: Int)
    case delete
  }

  static func createEvent(
    title: String, points: Int, completion: @escaping ((title: String, points: Int)) -> Void) -> UIAlertController {
    let (alert, titleTf, pointsTf) = self.eventAlert(alertTitle: "New Event", title: title, points: points)

    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
      let titleValue = titleTf.text ?? ""
      let pointsValue = Int(pointsTf.text ?? "") ?? 0
      completion((titleValue, pointsValue))
    })

    return alert
  }

  static func modifyEvent(
    title: String, points: Int, completion: @escaping (EventAction) -> Void) -> UIAlertController {
    let (alert, titleTf, pointsTf) = self.eventAlert(alertTitle: "Modify Event", title: title, points: points)

    alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
      let titleValue = titleTf.text ?? ""
      let pointsValue = Int(pointsTf.text ?? "") ?? 0
      completion(.update(title: titleValue, points: pointsValue))
    })
    alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
      completion(.delete)
    })
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

    return alert
  }

  private static func eventAlert(
    alertTitle: String,
    title: String,
    points: Int
  ) -> (alert: UIAlertController, title: UITextField, points: UITextField) {
    let alert = UIAlertController(
      title: alertTitle,
      message: "enter a title for the event",
      preferredStyle: .alert
    )
    let eventTitleTextField = alert.insertTextField { textField in
      textField.text = title
      textField.autocorrectionType = .yes
      textField.autocapitalizationType = .sentences
      textField.placeholder = "Event title"
    }
    let pointValueTextField = alert.insertTextField { textField in
      textField.text = String(points)
      textField.placeholder = "Points"
      textField.keyboardType = .numberPad
    }

    return (alert, eventTitleTextField, pointValueTextField)
  }
}
