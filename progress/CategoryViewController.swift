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
    let alert = UIAlertController(title: "Modify Category", message: nil, preferredStyle: .alert)

    let categoryTitleTextField = alert.insertTextField { textField in
      textField.text = self.category.title
      textField.placeholder = "Category title"
    }
    alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
      self.updateTitle(categoryTitleTextField.text.useIfEmptyOrNil("Untitled"))
    })
    alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
      self.deleteCategory()
    })
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
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

    return cell
  }
}
