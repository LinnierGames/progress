import UIKit
import PointsService

class ViewController: UIViewController {

  @IBOutlet weak var buttonTimeWindow: UIButton!
  @IBOutlet private weak var tableView: UITableView!

  private let pointsDataSource = injectPointsDataSource()

  private var timeWindow = TimeWindow(windowSize: .day)
  private var categories = [PointsService.Category]()

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

  @IBAction func pressPreviousTimeWindow(_ sender: Any) {
    timeWindow.previousWindow()
    updateUI()
  }

  @IBAction func pressAdjustTimeWindowSize(_ sender: Any) {
    let updateTimeWindowSize: (TimeWindow.WindowSize) -> Void = { newSize in
      self.timeWindow.windowSize = newSize
      self.updateUI()
    }
    let alertWindows = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

    TimeWindow.WindowSize.allCases.forEach { size in
      alertWindows.addAction(UIAlertAction(title: size.display, style: .default) { _ in
        updateTimeWindowSize(size)
      })
    }
    alertWindows.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    present(alertWindows, animated: true)
  }

  @IBAction func pressNextTimeWindow(_ sender: Any) {
    timeWindow.nextWindow()
    updateUI()
  }

  @IBAction func pressAddCategory(_ sender: Any) {
    let alert = UIAlertController.createCategory { title in
      self.createCategory(title: title.useIfEmpty("Untitled"))
    }
    self.present(alert, animated: true)
  }

  private func updateUI() {
    pointsDataSource.categories(timeRange: timeWindow.window).then { categories in
      self.categories = categories
      self.tableView.reloadData()
    }

    if case .day = timeWindow.windowSize {
      let start = timeWindow.window.lowerBound
      let startString = start.formattedStringWith(
        formatter: .Day_oftheWeekFullName, ", ", .Month_shorthand, " ", .Day_ofTheMonthNoPadding)
      buttonTimeWindow.setTitle(startString, for: .normal)
    } else {
      let start = timeWindow.window.lowerBound
      let end = timeWindow.window.upperBound
      let startString = start.formattedStringWith(
        formatter: .Day_oftheWeekFullName, ", ", .Month_shorthand, " ", .Day_ofTheMonthNoPadding)
      let endString = end.formattedStringWith(
        formatter: .Day_oftheWeekFullName, ", ", .Month_shorthand, " ", .Day_ofTheMonthNoPadding)
      buttonTimeWindow.setTitle("\(startString) - \(endString)", for: .normal)
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
