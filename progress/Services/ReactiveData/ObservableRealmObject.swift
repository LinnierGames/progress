import RealmSwift

open class ObservableRealmObject<Object: RealmSwift.Object>: ObservableBase {
  public let object: Object
  var token: NotificationToken!

  public init(object: Object) {
    self.object = object
    super.init()
    self.token = object.observe({ (change: ObjectChange<Object>) in
      switch change {
      case .change:
        self.notify()
      default: break
      }
    })
  }

  deinit {
    token?.invalidate()
  }
}
