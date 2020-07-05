import Foundation
import ReactiveData

class ObservableCategoryObject: ObservableRealmObject<CategoryObject>, Category {
  var rank: Rank {
    RankFactory.make(events: object.rawEvents, timeRange: timeRange)
  }

  var title: String {
    object.title
  }

  var rewards: [Reward] {
    object.rawRewards.map(ObservableRewardObject.init)
  }

  var events: [Event] {
    object.rawEvents.sorted(byKeyPath: "timestamp", ascending: false).map(ObservableEventObject.init)
  }

  private let timeRange: ClosedRange<Date>

  init(timeRange: ClosedRange<Date>, object: CategoryObject) {
    self.timeRange = timeRange
    super.init(object: object)
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
