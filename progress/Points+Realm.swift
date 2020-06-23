import RealmSwift

class CategoryObject: Object {
  @objc dynamic var title: String = ""
  let rawEvents = List<EventObject>()
}
extension CategoryObject: Category {
  var events: [Event] {
    self.rawEvents.map { $0 as Event }
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
