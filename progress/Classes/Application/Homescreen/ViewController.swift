import UIKit
import PointsService

class ViewController: UIViewController {

  @IBOutlet private weak var tableView: UITableView!

  var categories = [PointsService.Category]()

  private let pointsDataSource = injectPointsDataSource()

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.contentInset.bottom = 36 + 8
    tableView.verticalScrollIndicatorInsets.bottom = 36
    updateUI()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "show detailed event":
      guard
        let eventVC = segue.destination as? CategoryViewController,
        let cell = sender as? UITableViewCell,
        let indexPath = tableView.indexPath(for: cell)
      else {
        fatalError()
      }

      let category = categories[indexPath.row]
      eventVC.category = category
      eventVC.presentationController?.delegate = self
    default: break
    }
  }

  @IBAction func unwindToHomeScreen(unwindSegue: UIStoryboardSegue) {}

  @IBAction func pressAddCategory(_ sender: Any) {
    let alert = UIAlertController.createCategory { title in
      self.createCategory(title: title.useIfEmpty("Untitled"))
    }
    self.present(alert, animated: true)
  }

  private func updateUI() {
    let lower = Date(timeIntervalSinceNow: 60 * 60 * 24 * -7).midnight
    let upper = Date().endOfDay
    pointsDataSource.categories(timeRange: lower...upper).then { categories in
      self.categories = categories
      self.tableView.reloadData()
    }
  }

  private func createCategory(title: String) {
    pointsDataSource.createCategory(title: title).then {
      self.updateUI()
    }
  }

  private func createEvent(categoryIndexPath: IndexPath, points: Int, title: String) {
    let category = self.categories[categoryIndexPath.row]
    pointsDataSource.createEvent(title: title, points: points, category: category).then {
      self.tableView.reloadRows(at: [categoryIndexPath], with: .automatic)
    }
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
    guard points > 0 else { return }

    let alert = UIAlertController.createEvent(title: "", points: points) { title, points in
      guard
        let indexPath = self.tableView.indexPath(for: cell)
      else {
        return
      }

      self.createEvent(
        categoryIndexPath: indexPath,
        points: points,
        title: title.useIfEmpty("Untitled")
      )
    }
    self.present(alert, animated: true)
  }
}

extension ViewController: UIAdaptivePresentationControllerDelegate {
  func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
    viewWillAppear(true)
  }
}
