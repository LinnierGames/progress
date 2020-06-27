import RealmSwift

class CategoryObject: Object {
  @objc dynamic var title: String = ""
  let rawEvents = List<EventObject>()
  let rawRewards = List<RewardObject>()
}
extension CategoryObject: Category {
  var events: [Event] {
    self.rawEvents.map { $0 as Event }
  }
  var rewards: [Reward] {
    self.rawRewards.map { $0 as Reward }
  }
}

class EventObject: Object {
  @objc dynamic var title = ""
  @objc dynamic var points = 0
  @objc dynamic var timestamp = Date()
  dynamic var category: Category?
}
extension EventObject: Event {
}

class RewardObject: Object {
  @objc dynamic var title = ""
  @objc dynamic var points = 0
  @objc dynamic var isOneTimeReward = false
  dynamic var category: Category?
}
extension RewardObject: Reward {
}
