import Foundation
import Promises
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

public protocol PointsDataSource {
  func createCategory(title: String) -> Promise<Void>
  func categories() -> Promise<[Category]>
  func modifyCategory(title: String, category: Category) -> Promise<Void>
  func deleteCategory(_ category: Category) -> Promise<Void>

  func createReward(title: String, points: Int, isOneTimeReward: Bool, category: Category) -> Promise<Void>
  func modifyReward(title: String, points: Int, isOneTimeReward: Bool, reward: Reward) -> Promise<Void>
  func deleteReward(_ reward: Reward) -> Promise<Void>

  func createEvent(title: String, points: Int, category: Category) -> Promise<Void>
  func modifyEvent(title: String, points: Int, event: Event) -> Promise<Void>
  func deleteEvent(_ event: Event) -> Promise<Void>
}
