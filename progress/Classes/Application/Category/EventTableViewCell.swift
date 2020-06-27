import UIKit
import Points

class EventTableViewCell: UITableViewCell {
  @IBOutlet weak var labelTitle: UILabel!
  @IBOutlet weak var labelPoints: UILabel!
  @IBOutlet weak var labelTimestamp: UILabel!

  func configure(_ event: Event) {
    labelTitle.text = event.title
    labelPoints.text = "+\(event.points)"
    labelTimestamp.text =
      DateFormatter.localizedString(from: event.timestamp, dateStyle: .long, timeStyle: .short)
  }
}
