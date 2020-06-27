import UIKit

protocol CategoryTableViewCellDelegate: AnyObject {
  func category(_ cell: CategoryTableViewCell, didAddNewEvent points: Int)
}

class CategoryTableViewCell: UITableViewCell {
  var rank = Points.startingRank()
  weak var delegate: CategoryTableViewCellDelegate?

  private var currentProgress: Float {
    Float(self.rank.points) / Float(self.rank.pointsToNextLevel)
  }

  @IBOutlet weak var labelTitle: UILabel!
  @IBOutlet weak var labelRank: UILabel!
  @IBOutlet weak var sliderProgress: UIProgressView!
  @IBOutlet weak var labelPoints: UILabel!

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.commonInit()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.commonInit()
  }

  func configure(_ category: Category) {
    self.rank = Points.rank(for: category.points)
    self.labelTitle.text = category.title
    self.updateUI()
  }

  override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }
    return self.isGestureVertical(pan) == false//else { self.cancelGesture(gesture); return }
  }

  override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return false
  }

  private func commonInit() {
    let panGesture = UIPanGestureRecognizer(
      target: self,
      action: #selector(CategoryTableViewCell.panGesture(_:))
    )
    panGesture.delegate = self
    self.addGestureRecognizer(panGesture)
  }

  private func updateUI(pointsOffset: Int? = nil) {
    self.labelRank.text = rank.display()
    self.sliderProgress.progress =
      (
        Float(self.rank.points) + Float(pointsOffset ?? 0)
      )
      / Float(self.rank.pointsToNextLevel)

    if let pointsOffset = pointsOffset {
      self.labelPoints.text = "\(rank.points) +\(pointsOffset) / \(rank.pointsToNextLevel)"
    } else {
      self.labelPoints.text = "\(rank.points) / \(rank.pointsToNextLevel)"
    }
  }

  @objc private func panGesture(_ gesture: UIPanGestureRecognizer) {
    switch gesture.state {
    case .began:
      self.beginAddingAnEvent()
    case .changed:
      self.updateAddedEvent(gesture: gesture)
    case .ended:
      self.notifyNewEvent(gesture: gesture)
    default: break
    }
  }

  private func isGestureVertical(_ gesture: UIPanGestureRecognizer) -> Bool {
    let yTranslation = gesture.translation(in: self.superview).y
    return abs(yTranslation) > 5
  }

  private func cancelGesture(_ gesture: UIPanGestureRecognizer) {
    gesture.isEnabled = false
    gesture.isEnabled = true
  }

  private func beginAddingAnEvent() {
    // TODO: update UI with number badge
  }

  private var lastPoint: Int?
  private func updateAddedEvent(gesture: UIPanGestureRecognizer) {
    let pointsDiff = self.pointsDiff(fromPanGesture: gesture)

    // TODO: update UI with points

    if pointsDiff != lastPoint {
      let generator = UIImpactFeedbackGenerator(style: .medium)
      generator.impactOccurred()
    }
    self.lastPoint = pointsDiff

    self.updateUI(pointsOffset: pointsDiff)
  }

  private func notifyNewEvent(gesture: UIPanGestureRecognizer) {
    let pointsDiff = self.pointsDiff(fromPanGesture: gesture)
    self.delegate?.category(self, didAddNewEvent: pointsDiff)

    // reset UI
    self.updateUI()
  }

  private func pointsDiff(fromPanGesture gesture: UIPanGestureRecognizer) -> Int {
    let translation = gesture.translation(in: self.superview)
    let xTranslation = translation.x
    let yTranslation = translation.y
    let maxXTranslation = self.bounds.width
    let xDiffPercentage = Float(xTranslation) / Float(maxXTranslation)

    guard xDiffPercentage >= 0 else { return 0 }

    let scale = max(Int(Float(abs(yTranslation)) / Float(64)), 1)
    let maxPoints = 50 * scale

    return Int(Float(maxPoints) * xDiffPercentage)
  }
}
