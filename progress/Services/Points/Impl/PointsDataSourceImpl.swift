import Foundation
import RealmSwift
import Promises
import ReactiveData

class PointsDataSourceImpl: PointsDataSource {

  let realm = RealmExecutor()

  func createCategory(title: String) -> Promise<Void> {
    realm.execute { realm in
      try realm.write {
        let newCategory = CategoryObject()
        newCategory.title = title
        realm.add(newCategory)
      }
    }
  }

  func categories() -> Promise<[Category]> {
    realm.execute { realm in
      realm.objects(CategoryObject.self)
        .sorted(byKeyPath: "title")
        .map { ObservableCategoryObject(object: $0) }
    }
  }

  func modifyCategory(title: String, category: Category) -> Promise<Void> {
    guard let observable = category as? ObservableCategoryObject else { return Promise {} }
    return realm.execute { realm in
      try realm.write {
        observable.object.title = title
        realm.add(observable.object)
      }
    }
  }

  func deleteCategory(_ category: Category) -> Promise<Void> {
    guard let observable = category as? ObservableCategoryObject else { return Promise {} }
    return realm.execute { realm in
      try realm.write {
        realm.delete(observable.object)
      }
    }
  }

  func createReward(title: String, points: Int, isOneTimeReward: Bool, category: Category) -> Promise<Void> {
    guard let observable = category as? ObservableCategoryObject else { return Promise {} }
    return realm.execute { realm in
      try realm.write {
        let newReward = RewardObject()
        newReward.points = points
        newReward.title = title
        newReward.isOneTimeReward = isOneTimeReward
        newReward.category = observable.object
        observable.object.rawRewards.append(newReward)
        realm.add(newReward)
      }
    }
  }

  func modifyReward(title: String, points: Int, isOneTimeReward: Bool, reward: Reward) -> Promise<Void> {
    guard let observable = reward as? ObservableRewardObject else { return Promise {} }
    return realm.execute { realm in
      try realm.write {
        let object = observable.object
        object.title = title
        object.points = points
        object.isOneTimeReward = isOneTimeReward
        realm.add(object)
      }
    }
  }

  func deleteReward(_ reward: Reward) -> Promise<Void> {
    guard let observable = reward as? ObservableRewardObject else { return Promise {} }
    return realm.execute { realm in
      try realm.write {
        realm.delete(observable.object)
      }
    }
  }

  func createEvent(title: String, points: Int, category: Category) -> Promise<Void> {
    guard let observable = category as? ObservableCategoryObject else { return Promise {} }
    return realm.execute { realm in
      try realm.write {
        let newEvent = EventObject()
        newEvent.points = points
        newEvent.title = title
        newEvent.timestamp = Date()
        newEvent.category = observable.object
        observable.object.rawEvents.append(newEvent)
        realm.add(newEvent)
      }
    }
  }

  func modifyEvent(title: String, points: Int, event: Event) -> Promise<Void> {
    guard let observable = event as? ObservableEventObject else { return Promise {} }
    return realm.execute { realm in
      try realm.write {
        let object = observable.object
        object.title = title
        object.points = points
        realm.add(object)
      }
    }
  }

  func deleteEvent(_ event: Event) -> Promise<Void> {
    guard let observable = event as? ObservableEventObject else { return Promise {} }
    return realm.execute { realm in
      try realm.write {
        realm.delete(observable.object)
      }
    }
  }
}





