//
//  ViewController.swift
//  progress
//
//  Created by Erick Sanchez on 6/20/20.
//  Copyright © 2020 Erick Sanchez. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet private weak var tableView: UITableView!

  var categories = [Category]()

  private func createCategory(title: String) {
    let newCategory = Category(title: title)
    self.categories.insert(newCategory, at: 0)
    self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
  }

  private func createEvent(categoryIndexPath: IndexPath, points: Int, title: String) {
    let category = self.categories[categoryIndexPath.row]
    let newEvent = Event(title: title, points: points, timestamp: Date())
    category.events.insert(newEvent, at: 0)
    self.tableView.reloadRows(at: [categoryIndexPath], with: .automatic)
  }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categories.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "category", for: indexPath) as! CategoryTableViewCell

    let category = self.categories[indexPath.row]
    cell.configure(category)
    cell.delegate = self

    return cell
  }
}

extension ViewController: CategoryTableViewCellDelegate {
  func category(_ cell: CategoryTableViewCell, didAddNewEvent points: Int) {
    let alert = UIAlertController(title: "New Event", message: "enter a title for the event", preferredStyle: .alert)
    let pointValueTextField = alert.insertTextField { textField in
      textField.text = String(points)
      textField.placeholder = "Points"
      textField.keyboardType = .numberPad
    }
    let eventTitleTextField = alert.insertTextField { textField in
      textField.placeholder = "Event title"
    }
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
      guard
        let pointsString = pointValueTextField.text,
        let points = Int(pointsString),
        let indexPath = self.tableView.indexPath(for: cell)
      else {
        return
      }

      self.createEvent(
        categoryIndexPath: indexPath,
        points: points,
        title: eventTitleTextField.text.useIfEmptyOrNil("Untitled")
      )
    })
    self.present(alert, animated: true)
  }
}

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

// MARK - IBActions

extension ViewController {
  @IBAction func unwindToHomeScreen(unwindSegue: UIStoryboardSegue) {
    //    unwindSegue.source.parent?.dismiss(animated: true, completion: nil)
  }

  @IBAction func pressAddCategory(_ sender: Any) {
    // TODO: create alert
    self.createCategory(title: "Foobar")
  }
}
