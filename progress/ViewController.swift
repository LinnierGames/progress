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

  let realm = try! Realm()

  var categories = [Category]()

  override func viewDidLoad() {
    super.viewDidLoad()

    categories = realm.objects(CategoryObject.self).map { $0 as Category }
    self.tableView.reloadData()
  }

  private func createCategory(title: String) {
    try! realm.write {
      let newCategory = CategoryObject()
      newCategory.title = title
      realm.add(newCategory)
      self.categories.insert(newCategory, at: 0)
    }
    self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
  }

  private func createEvent(categoryIndexPath: IndexPath, points: Int, title: String) {
    guard points > 0 else { return }

    try! realm.write {
      let category = self.categories[categoryIndexPath.row] as! CategoryObject
      let newEvent = EventObject()
      newEvent.points = points
      newEvent.title = title
      newEvent.timestamp = Date()
      newEvent.category = category
      category.rawEvents.append(newEvent)
      realm.add(newEvent)
    }

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

// MARK - IBActions

extension ViewController {
  @IBAction func unwindToHomeScreen(unwindSegue: UIStoryboardSegue) {
    //    unwindSegue.source.parent?.dismiss(animated: true, completion: nil)
  }

  @IBAction func pressAddCategory(_ sender: Any) {
    let alert = UIAlertController(
      title: "New Category",
      message: "enter a name",
      preferredStyle: .alert
    )

    let categoryTitleTextField = alert.insertTextField { textField in
      textField.placeholder = "Category title"
    }
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
      self.createCategory(title: categoryTitleTextField.text.useIfEmptyOrNil("Untitled"))
    })
    self.present(alert, animated: true)
  }
}







import RealmSwift

class CategoryObject: Object {
  @objc dynamic var title: String = ""
  let rawEvents = List<EventObject>()
}
extension CategoryObject: Category {
  var events: [Event] {
    self.rawEvents.map { $0 as Event }
  }
}

class EventObject: Object {
  @objc dynamic var title = ""
  @objc dynamic var points = 0
  @objc dynamic var timestamp = Date()
  dynamic var category: Category?
}
extension EventObject: Event {
}
