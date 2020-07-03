import Foundation
import ReactiveData

public protocol Category: Observable {
  var title: String { get }
  var events: [Event] { get }
  var rewards: [Reward] { get }
}

extension Category {
  public var points: Int {
    return events.reduce(0, { $0 + $1.points })
  }
}

public protocol Event: Observable {
  var title: String { get }
  var points: Int { get }
  var timestamp: Date { get }
}

public protocol Reward: Observable {
  var title: String { get }
  var points: Int { get }
  var isOneTimeReward: Bool { get }
}
