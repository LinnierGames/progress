import UIKit
import PointsService

@objc protocol ProgressContainerViewDelegate: AnyObject {
  func progress(_ view: ProgressContainerView, didAddNewEvent points: Int)
}

class ProgressContainerView: UIView, UIGestureRecognizerDelegate {
  let progressLabel = UILabel()
  @IBOutlet weak var delegate: ProgressContainerViewDelegate?

  var progressColor: UIColor = .blue { didSet { updateUI() } }
  var additionalProgressColor: UIColor = .green { didSet { updateUI() } }

  let contentLayoutGuide = UILayoutGuide()

  private let progressView: ProgressView
  private var rank: Points.Rank = Points.startingRank()

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

  func set(rank: Points.Rank) {
    self.rank = rank
    updateProgress()
  }

  // MARK: - UIGestureRecognizerDelegate

  override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }
    return self.isGestureVertical(pan) == false//else { self.cancelGesture(gesture); return }
  }

  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return false
  }

  // MARK: - Private

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
    let contentLayoutGuideTopConstraint =
      contentLayoutGuide.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor)
    contentLayoutGuideTopConstraint.priority = .defaultHigh
    NSLayoutConstraint.activate([
      contentLayoutGuide.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
      contentLayoutGuide.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
      contentLayoutGuide.topAnchor.constraint(equalTo: stackView.topAnchor),
      contentLayoutGuide.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
      progressView.heightAnchor.constraint(equalToConstant: 8),

      contentLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor),
      contentLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor),
      contentLayoutGuideTopConstraint,
      contentLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])

    let panGesture = UIPanGestureRecognizer(
      target: self,
      action: #selector(ProgressContainerView.panGesture(_:))
    )
    panGesture.delegate = self
    self.addGestureRecognizer(panGesture)
  }

  private func updateUI() {
    progressView.primaryColor = progressColor
    progressView.secondaryColor = additionalProgressColor
  }

  private func updateProgress(pointsOffset: Int? = nil) {
    self.progressLabel.text = rank.display()
    progressView.progress = CGFloat(self.rank.points) / CGFloat(self.rank.pointsToNextLevel)
    progressView.additionalProgress = CGFloat(pointsOffset ?? 0) / CGFloat(self.rank.pointsToNextLevel)

    if let pointsOffset = pointsOffset {
      self.progressLabel.text = "\(rank.points) +\(pointsOffset) / \(rank.pointsToNextLevel)"
    } else {
      self.progressLabel.text = "\(rank.points) / \(rank.pointsToNextLevel)"
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

    self.updateProgress(pointsOffset: pointsDiff)
  }

  private func notifyNewEvent(gesture: UIPanGestureRecognizer) {
    let pointsDiff = self.pointsDiff(fromPanGesture: gesture)
    self.delegate?.progress(self, didAddNewEvent: pointsDiff)

    // reset UI
    self.updateProgress()
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
