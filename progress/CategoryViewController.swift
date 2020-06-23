import UIKit
import RealmSwift

class CategoryViewController: UIViewController {
  var category: Category!

  @IBOutlet weak var labelRank: UILabel!
  @IBOutlet weak var labelTitle: UILabel!
  @IBOutlet weak var sliderProgress: UIProgressView!
  @IBOutlet weak var labelProgress: UILabel!
  @IBOutlet weak var collectionRewards: UICollectionView!
  @IBOutlet weak var tableEvents: UITableView!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableEvents.dataSource = self
    tableEvents.delegate = self
    updateUI()
  }

  @IBAction func pressModify(_ sender: Any) {
    let alert = UIAlertController.modifyCategory(title: category.title) { action in
      switch action {
      case .update(let newTitle):
        self.updateTitle(newTitle.useIfEmpty("Untitled"))
      case .delete:
        self.deleteCategory()
      }
    }
    self.present(alert, animated: true)
  }

  private func updateUI() {
    let rank = Points.rank(for: category.points)
    labelRank.text = String(rank.rank)
    labelTitle.text = category.title
    sliderProgress.progress = 0 // TODO: update progres by creating custom UI element
    labelProgress.text = ""
  }

  private func updateTitle(_ newTitle: String) {
    if let object = category as? CategoryObject {
      let realm = try! Realm()
      try! realm.write {
        object.title = newTitle
      }
    }

    updateUI()
  }

  private func deleteCategory() {
    if let object = category as? CategoryObject {
      let realm = try! Realm()
      try! realm.write {
        realm.delete(object)
      }
    }

    self.presentationController.map {
      $0.delegate?.presentationControllerWillDismiss?($0)
    }
    self.presentingViewController?.dismiss(animated: true)
  }
}

extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return category.events.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "event",
      for: indexPath
    ) as! EventTableViewCell

    let event = category.events[indexPath.row]
    cell.configure(event)
    cell.accessoryType = .disclosureIndicator

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let event = category.events[indexPath.row]
    let alert = UIAlertController.modifyEvent(title: event.title, points: event.points) { action in
      switch action {
      case .update(let newTitle, let newPoints):
        if let object = event as? EventObject {
          let realm = try! Realm()
          try! realm.write {
            object.title = newTitle
            object.points = newPoints
          }

          tableView.reloadRows(at: [indexPath], with: .automatic)
          self.updateUI()
        }
      case .delete:
        if let object = event as? EventObject {
          let realm = try! Realm()
          try! realm.write {
            realm.delete(object)
          }

          tableView.deleteRows(at: [indexPath], with: .automatic)
          self.updateUI()
        }
      }
    }
    present(alert, animated: true)
  }

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    switch editingStyle {
    case .delete:
      let event = category.events[indexPath.row]
      if let object = event as? EventObject {
        let realm = try! Realm()
        try! realm.write {
          realm.delete(object)
        }

        tableView.deleteRows(at: [indexPath], with: .automatic)
        self.updateUI()
      }
    default: break
    }
  }
}
