import UIKit
import PointsService
import Combine

class CategoryViewController: UIViewController, ProgressContainerViewDelegate {
  var category: PointsService.Category!

  @IBOutlet weak var labelRank: UILabel!
  @IBOutlet weak var labelTitle: UILabel!
  @IBOutlet weak var progressView: ProgressContainerView!
  @IBOutlet weak var collectionRewards: UICollectionView!
  @IBOutlet weak var tableEvents: UITableView!

  private let pointsDataSource = injectPointsDataSource()
  private var bag = Set<AnyCancellable>()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableEvents.dataSource = self
    tableEvents.delegate = self
    collectionRewards.dataSource = self
    collectionRewards.delegate = self

    updateUI()
    category.didChange.sink(receiveCompletion: { _ in }, receiveValue: updateUI).store(in: &bag)
  }

  @IBAction func pressModify(_ sender: Any) {
    let alert = UIAlertController.modifyCategory(title: category.title) { action in
      switch action {
      case .update(let newTitle):
        _ = self.pointsDataSource.modifyCategory(title: newTitle.useIfEmpty("Untitled"), category: self.category)
      case .delete:
        self.deleteCategory()
      }
    }
    self.present(alert, animated: true)
  }

  @IBAction func pressAddReward(_ sender: Any) {
    let alert = UIAlertController.createReward { title, points in
      self.pointsDataSource.createReward(title: title, points: points, isOneTimeReward: false, category: self.category)
    }
    present(alert, animated: true)
  }

  @IBAction func pressAddEvent(_ sender: Any) {
    let alert = UIAlertController.createEvent(title: "", points: 0) { title, points in
      self.pointsDataSource.createEvent(title: title.useIfEmpty("Untitled"), points: points, category: self.category)
//      self.tableEvents.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
//      self.updateUI()
    }
    present(alert, animated: true)
    UIButton().titleLabel?.numberOfLines = 0
  }

  // MARK: - ProgressContainerViewDelegate

  func progress(_ view: ProgressContainerView, didAddNewEvent points: Int) {
    guard points > 0 else { return }

    let alert = UIAlertController.createEvent(title: "", points: points) { title, points in
      self.pointsDataSource.createEvent(title: title.useIfEmpty("Untitled"), points: points, category: self.category)
    }
    self.present(alert, animated: true)
  }

  // MARK: - Private

  private func updateUI() {
    let rank = category.rank
    labelRank.text = String(rank.rank)
    labelTitle.text = category.title
    progressView.set(rank: rank)
    collectionRewards.reloadData()
    tableEvents.reloadData()
  }

  private func deleteCategory() {
    pointsDataSource.deleteCategory(category).then {
      self.presentationController.map {
        $0.delegate?.presentationControllerWillDismiss?($0)
      }
      self.presentingViewController?.dismiss(animated: true)
    }
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
        let event = self.category.events[indexPath.row]
        _ = self.pointsDataSource.modifyEvent(title: newTitle, points: newPoints, event: event)
//        self.tableEvents.reloadRows(at: [indexPath], with: .automatic)
//        self.updateUI()
      case .delete:
        let event = self.category.events[indexPath.row]
        self.pointsDataSource.deleteEvent(event).then {
//          self.tableEvents.deleteRows(at: [indexPath], with: .automatic)
//          self.updateUI()
        }
      }
    }
    present(alert, animated: true)
  }

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    switch editingStyle {
    case .delete:
      let event = self.category.events[indexPath.row]
      self.pointsDataSource.deleteEvent(event).then {
//        self.tableEvents.deleteRows(at: [indexPath], with: .automatic)
      }
//      self.updateUI()
    default: break
    }
  }
}

extension CategoryViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return category.rewards.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rewards", for: indexPath) as! RewardCollectionViewCell
    let reward = category.rewards[indexPath.item]
    cell.configure(reward)
    cell.delegate = self

    return cell
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let rewarad = category.rewards[indexPath.item]
    _ = pointsDataSource.createEvent(title: rewarad.title, points: rewarad.points, category: category)

    if rewarad.isOneTimeReward {
      let reward = category.rewards[indexPath.item]
      pointsDataSource.deleteReward(reward)
    }

//    tableEvents.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
//    updateUI()
  }
}

extension CategoryViewController: RewardCollectionViewCellDelegate {
  func rewardDidTapToModify(_ cell: RewardCollectionViewCell) {
    guard let indexPath = collectionRewards.indexPath(for: cell) else { return }
    let reward = category.rewards[indexPath.item]
    let alert = UIAlertController.modifyReward(title: reward.title, points: reward.points) { action in
      switch action {
      case .update(let newTitle, let newPoints):
        let reward = self.category.rewards[indexPath.item]
        self.pointsDataSource.modifyReward(title: newTitle, points: newPoints, isOneTimeReward: false, reward: reward)
      case .delete:
        let reward = self.category.rewards[indexPath.item]
        self.pointsDataSource.deleteReward(reward)
      }
      self.collectionRewards.reloadData()
    }
    present(alert, animated: true)
  }
}

protocol RewardCollectionViewCellDelegate: AnyObject {
  func rewardDidTapToModify(_ cell: RewardCollectionViewCell)
}

class RewardCollectionViewCell: UICollectionViewCell {
  private var longTapGesture: UILongPressGestureRecognizer!

  @IBOutlet private weak var labelTitle: UILabel!
  @IBOutlet private weak var labelPoints: UILabel!

  weak var delegate: RewardCollectionViewCellDelegate?

  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }

  private func commonInit() {
    longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(RewardCollectionViewCell.didLongPress(_:)))
    addGestureRecognizer(longTapGesture)
  }

  func configure(_ reward: Reward) {
    labelTitle.text = reward.title
    labelPoints.text = "\(reward.points) pts"
  }

  @objc private func didLongPress(_ sender: Any) {
    delegate?.rewardDidTapToModify(self)
  }
}
