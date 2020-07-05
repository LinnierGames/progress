import UIKit
import PointsService

protocol CategoryTableViewCellDelegate: AnyObject {
  func category(_ cell: CategoryTableViewCell, didAddNewEvent points: Int)
}

class CategoryTableViewCell: UITableViewCell, ProgressContainerViewDelegate {
  weak var delegate: CategoryTableViewCellDelegate?

  @IBOutlet weak var labelTitle: UILabel!
  @IBOutlet weak var labelRank: UILabel!
  @IBOutlet weak var progressView: ProgressContainerView!

  @IBOutlet weak var stackViewContent: UIStackView!

  func configure(_ category: PointsService.Category) {
    let rank = category.rank
    progressView.set(rank: rank)
    self.labelTitle.text = category.title
    self.labelRank.text = rank.display()
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    progressView.contentLayoutGuide.topAnchor.constraint(
      equalTo: stackViewContent.bottomAnchor, constant: 4
    ).isActive = true
  }

  // MARK: - ProgressContainerViewDelegate

  func progress(_ view: ProgressContainerView, didAddNewEvent points: Int) {
    delegate?.category(self, didAddNewEvent: points)
  }
}
