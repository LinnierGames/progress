import RealmSwift
import ReactiveData
import Combine

public class CategoryObject: Object, ObservableBaseProtocol {
  public var objectDidChange = PassthroughSubject<Void, ObservableErrors>()

  @objc dynamic public var title: String = "" { didSet { notifyIfNew(title, old: oldValue) } }
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

public class EventObject: Object, ObservableBaseProtocol {
  public var objectDidChange = PassthroughSubject<Void, ObservableErrors>()

  @objc dynamic public var title = "" { didSet { notifyIfNew(title, old: oldValue) } }
  @objc dynamic public var points = 0 { didSet { notifyIfNew(points, old: oldValue) } }
  @objc dynamic public var timestamp = Date() { didSet { notifyIfNew(timestamp, old: oldValue) } }
  dynamic public var category: Category? { didSet { notify() } }
}
extension EventObject: Event {
}

public class RewardObject: Object, ObservableBaseProtocol {
  public var objectDidChange = PassthroughSubject<Void, ObservableErrors>()

  @objc dynamic public var title = "" { didSet { notifyIfNew(title, old: oldValue) } }
  @objc dynamic public var points = 0 { didSet { notifyIfNew(points, old: oldValue) } }
  @objc dynamic public var isOneTimeReward = false { didSet { notifyIfNew(isOneTimeReward, old: oldValue) } }
  dynamic public var category: Category? { didSet { notify() } }
}
extension RewardObject: Reward {
}
