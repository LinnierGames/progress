import RealmSwift

public class CategoryObject: Object {
  @objc dynamic public var title: String = ""
  public let rawEvents = List<EventObject>()
  public let rawRewards = List<RewardObject>()
}
extension CategoryObject: Category {
  public var events: [Event] {
    self.rawEvents.map { $0 as Event }
  }
  public var rewards: [Reward] {
    self.rawRewards.map { $0 as Reward }
  }
}

public class EventObject: Object {
  @objc dynamic public var title = ""
  @objc dynamic public var points = 0
  @objc dynamic public var timestamp = Date()
  dynamic public var category: Category?
}
extension EventObject: Event {
}

public class RewardObject: Object {
  @objc dynamic public var title = ""
  @objc dynamic public var points = 0
  @objc dynamic public var isOneTimeReward = false
  dynamic public var category: Category?
}
extension RewardObject: Reward {
}
