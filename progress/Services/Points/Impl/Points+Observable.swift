import Foundation
import ReactiveData

typealias ObservableCategoryObject = ObservableRealmObject<CategoryObject>
extension ObservableCategoryObject: Category {
  public var title: String {
    object.title
  }

  public var rewards: [Reward] {
    object.rawRewards.map(ObservableRewardObject.init)
  }

  public var events: [Event] {
    object.rawEvents.sorted(byKeyPath: "timestamp", ascending: false).map(ObservableEventObject.init)
  }
}

typealias ObservableRewardObject = ObservableRealmObject<RewardObject>
extension ObservableRewardObject: Reward {
  public var title: String {
    object.title
  }

  public var points: Int {
    object.points
  }

  public var isOneTimeReward: Bool {
    object.isOneTimeReward
  }
}

typealias ObservableEventObject = ObservableRealmObject<EventObject>
extension ObservableEventObject: Event {
  public var title: String {
    object.title
  }

  public var points: Int {
    object.points
  }

  public var timestamp: Date {
    object.timestamp
  }
}
