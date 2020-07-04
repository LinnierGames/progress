import RealmSwift

class CategoryObject: Object {
  @objc dynamic var title: String = ""
  let rawEvents = List<EventObject>()
  let rawRewards = List<RewardObject>()
}

class EventObject: Object {
  @objc dynamic var title = ""
  @objc dynamic var points = 0
  @objc dynamic var timestamp = Date()
  dynamic var category: CategoryObject?
}

class RewardObject: Object {
  @objc dynamic var title = ""
  @objc dynamic var points = 0
  @objc dynamic var isOneTimeReward = false
  dynamic var category: CategoryObject?
}
