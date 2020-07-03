import UIKit
import PointsService

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
//  @IBOutlet weak var sliderProgress: UIProgressView!
  @IBOutlet weak var progressView: ProgressContainerView!
//  @IBOutlet weak var labelPoints: UILabel!

  @IBOutlet weak var stackViewContent: UIStackView!

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.commonInit()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.commonInit()
  }

  func configure(_ category: PointsService.Category) {
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

  override func awakeFromNib() {
    super.awakeFromNib()
    progressView.contentLayoutGuide.topAnchor.constraint(
      equalTo: stackViewContent.bottomAnchor, constant: 4
    ).isActive = true
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
    self.progressView.set(
      value: CGFloat(self.rank.points) / CGFloat(self.rank.pointsToNextLevel),
      additionalProgress: CGFloat(pointsOffset ?? 0) / CGFloat(self.rank.pointsToNextLevel)
    )

    if let pointsOffset = pointsOffset {
      self.progressView.progressLabel.text = "\(rank.points) +\(pointsOffset) / \(rank.pointsToNextLevel)"
    } else {
      self.progressView.progressLabel.text = "\(rank.points) / \(rank.pointsToNextLevel)"
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

//layout bar, points label
//add pan gesture
//display additional bar
//display badge icon
//expose layout guide

//@IBDesignable
class ProgressContainerView: UIView {
  @IBInspectable
  var progressColor: UIColor = .blue { didSet { updateUI() } }
  @IBInspectable
  var additionalProgressColor: UIColor = .green { didSet { updateUI() } }

  let contentLayoutGuide = UILayoutGuide()

  private let progressView: ProgressView
  init() {
    self.progressView = ProgressView()
    super.init(frame: .zero)
    commonInit()
  }

  required init?(coder: NSCoder) {
    self.progressView = ProgressView()
    super.init(coder: coder)
    commonInit()
  }

  func set(value: CGFloat, additionalProgress: CGFloat = 0) {
    progressView.progress = value
    progressView.additionalProgress = additionalProgress
  }

  let progressLabel = UILabel()
  private func commonInit() {
    backgroundColor = .clear

    progressLabel.textAlignment = .center

    let stackView = UIStackView(arrangedSubviews: [
      progressView,
      progressLabel,
    ])
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.spacing = 4

    addSubview(stackView)
    addLayoutGuide(contentLayoutGuide)
    NSLayoutConstraint.activate([
      contentLayoutGuide.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
      contentLayoutGuide.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
      contentLayoutGuide.topAnchor.constraint(equalTo: stackView.topAnchor),
      contentLayoutGuide.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
      progressView.heightAnchor.constraint(equalToConstant: 8),

      contentLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor),
      contentLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor),
      contentLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.topAnchor),
      contentLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  private func updateUI() {
    progressView.primaryColor = progressColor
    progressView.secondaryColor = additionalProgressColor
  }
}

private class ProgressView: UIView {
  var primaryColor = UIColor.blue { didSet { updateUI() } }
  var secondaryColor = UIColor.green { didSet { updateUI() } }
  var progress: CGFloat = 0.2 { didSet { updateUI() } }
  var additionalProgress: CGFloat = 0.1 { didSet { updateUI() } }

  override var frame: CGRect { didSet { updateUI() } }
  override var bounds: CGRect { didSet { updateUI() } }

  private let progressBar = UIView()
  private let additionalProgressBar = UIView()

  override var intrinsicContentSize: CGSize {
    return CGSize(width: 32, height: 32)
  }

  init() {
    super.init(frame: .zero)
    commonInit()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    updateUI()
  }

  private func commonInit() {
    clipsToBounds = true
    backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    addSubview(progressBar)
    addSubview(additionalProgressBar)
  }

  private func updateUI() {
    progressBar.backgroundColor = primaryColor
    additionalProgressBar.backgroundColor = secondaryColor

    // todo: max width is bounds.width
    let progressBarWidth = bounds.width * progress
    progressBar.frame = CGRect(x: 0, y: 0, width: progressBarWidth, height: bounds.height)
    let additionalProgressBarWidth = bounds.width * additionalProgress
    additionalProgressBar.frame =
      CGRect(x: progressBarWidth, y: 0, width: additionalProgressBarWidth, height: bounds.height)
  }
}
