import UIKit
import PointsService

@objc protocol ProgressContainerViewDelegate: AnyObject {
  func progress(_ view: ProgressContainerView, didAddNewEvent points: Int)
}

class ProgressContainerView: UIView, UIGestureRecognizerDelegate {
  let progressLabel = UILabel()
  @IBOutlet weak var delegate: ProgressContainerViewDelegate?

  var progressColor: UIColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1) { didSet { updateUI() } }
  var progressColorInTimeRange: UIColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1) { didSet { updateUI() } }
  var additionalProgressColor: UIColor = #colorLiteral(red: 0.5563425422, green: 0.9793455005, blue: 0, alpha: 1) { didSet { updateUI() } }

  let contentLayoutGuide = UILayoutGuide()

  private let progressView: ProgressView
  private var rank: Rank?

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

  func set(rank: Rank) {
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

    updateUI()
  }

  private func updateUI() {
    progressView.progressBarColor1 = progressColor
    progressView.progressBarColor2 = progressColorInTimeRange
    progressView.progressBarColor3 = additionalProgressColor
  }

  private func updateProgress(pointsOffset: Int? = nil) {
    guard let rank = rank else { return }

    self.progressLabel.text = rank.display()
    let points = rank.pointsInLevel + rank.pointsInTimeWindow
    progressView.progress1 = CGFloat(rank.pointsInLevel) / CGFloat(rank.pointsToNextLevel)
    progressView.progress2 = CGFloat(rank.pointsInTimeWindow) / CGFloat(rank.pointsToNextLevel)
    progressView.progress3 = CGFloat(pointsOffset ?? 0) / CGFloat(rank.pointsToNextLevel)

    if let pointsOffset = pointsOffset {
      self.progressLabel.text = "\(points) +\(pointsOffset) / \(rank.pointsToNextLevel)"
    } else {
      self.progressLabel.text = "\(points) / \(rank.pointsToNextLevel)"
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
  var progressBarColor1 = UIColor.blue { didSet { updateUI() } }
  var progressBarColor2 = UIColor.green { didSet { updateUI() } }
  var progressBarColor3 = UIColor.green { didSet { updateUI() } }
  var progress1: CGFloat = 0.2 { didSet { updateUI() } }
  var progress2: CGFloat = 0.1 { didSet { updateUI() } }
  var progress3: CGFloat = 0.1 { didSet { updateUI() } }

  override var frame: CGRect { didSet { updateUI() } }
  override var bounds: CGRect { didSet { updateUI() } }

  private let progressBar1 = UIView()
  private let progressBar2 = UIView()
  private let progressBar3 = UIView()

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
    addSubview(progressBar1)
    addSubview(progressBar2)
    addSubview(progressBar3)
  }

  private func updateUI() {
    progressBar1.backgroundColor = progressBarColor1
    progressBar2.backgroundColor = progressBarColor2
    progressBar3.backgroundColor = progressBarColor3

    // todo: max width is bounds.width
    _ = [
      (progressBar1, progress1),
      (progressBar2, progress2),
      (progressBar3, progress3),
    ].reduce(0) { (xOffset: CGFloat, pair) in
      let (view, progress) = pair
      let progressBarWidth = bounds.width * progress
      view.frame = CGRect(x: xOffset, y: 0, width: progressBarWidth, height: bounds.height)
      return progressBarWidth + xOffset
    }
  }
}
