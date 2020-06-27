import UIKit
import RealmSwift
import PointsService

class CategoryViewController: UIViewController {
  var category: PointsService.Category!

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
    collectionRewards.dataSource = self
    collectionRewards.delegate = self
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

  @IBAction func pressAddReward(_ sender: Any) {
    let alert = UIAlertController.createReward { title, points in
      self.createReward(title: title, points: points, isOneTimeReward: false)
      self.collectionRewards.reloadData()
    }
    present(alert, animated: true)
  }

  @IBAction func pressAddEvent(_ sender: Any) {
    let alert = UIAlertController.createEvent(title: "", points: 0) { title, points in
      self.createEvent(title: title, points: points)
      self.tableEvents.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
      self.updateUI()
    }
    present(alert, animated: true)
    UIButton().titleLabel?.numberOfLines = 0
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

  private func createReward(title: String, points: Int, isOneTimeReward: Bool) {
    guard let category = category as? CategoryObject else { return }

    let realm = try! Realm()
    try! realm.write {
      let newReward = RewardObject()
      newReward.points = points
      newReward.title = title
      newReward.isOneTimeReward = isOneTimeReward
      newReward.category = category
      category.rawRewards.append(newReward)
      realm.add(newReward)
    }
  }

  private func updateReward(indexPath: IndexPath, title: String, points: Int) {
    guard let object = category.rewards[indexPath.item] as? RewardObject else { return }

    let realm = try! Realm()
    try! realm.write {
      object.title = title
      object.points = points
    }
  }

  private func deleteReward(indexPath: IndexPath) {
    guard let categoryObject = category as? CategoryObject else { return }

    let rewardObject = categoryObject.rawRewards[indexPath.item]
    let realm = try! Realm()
    try! realm.write {
      categoryObject.rawRewards.remove(at: indexPath.item)
      realm.delete(rewardObject)
    }
  }

  private func createEvent(title: String, points: Int) {
    guard let category = category as? CategoryObject else { return }

    let realm = try! Realm()
    try! realm.write {
      let newEvent = EventObject()
      newEvent.points = points
      newEvent.title = title
      newEvent.timestamp = Date()
      newEvent.category = category
      category.rawEvents.insert(newEvent, at: 0)
      realm.add(newEvent)
    }
  }

  private func updateEvent(indexPath: IndexPath, title: String, points: Int) {
    guard let object = category.events[indexPath.row] as? EventObject else { return }

    let realm = try! Realm()
    try! realm.write {
      object.title = title
      object.points = points
    }
  }

  private func deleteEvent(indexPath: IndexPath) {
    guard let categoryObject = category as? CategoryObject else { return }

    let eventObject = categoryObject.rawEvents[indexPath.row]
    let realm = try! Realm()
    try! realm.write {
      categoryObject.rawEvents.remove(at: indexPath.row)
      realm.delete(eventObject)
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
        self.updateEvent(indexPath: indexPath, title: newTitle, points: newPoints)
        self.tableEvents.reloadRows(at: [indexPath], with: .automatic)
        self.updateUI()
      case .delete:
        self.deleteEvent(indexPath: indexPath)
        self.tableEvents.deleteRows(at: [indexPath], with: .automatic)
        self.updateUI()
      }
    }
    present(alert, animated: true)
  }

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    switch editingStyle {
    case .delete:
      deleteEvent(indexPath: indexPath)
      tableView.deleteRows(at: [indexPath], with: .automatic)
      self.updateUI()
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
    createEvent(title: rewarad.title, points: rewarad.points)

    if rewarad.isOneTimeReward {
      deleteReward(indexPath: indexPath)
    }

    tableEvents.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    updateUI()
  }
}

extension CategoryViewController: RewardCollectionViewCellDelegate {
  func rewardDidTapToModify(_ cell: RewardCollectionViewCell) {
    guard let indexPath = collectionRewards.indexPath(for: cell) else { return }
    let reward = category.rewards[indexPath.item]
    let alert = UIAlertController.modifyReward(title: reward.title, points: reward.points) { action in
      switch action {
      case .update(let newTitle, let newPoints):
        self.updateReward(indexPath: indexPath, title: newTitle, points: newPoints)
      case .delete:
        self.deleteReward(indexPath: indexPath)
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
