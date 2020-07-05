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

  func categories(timeRange: ClosedRange<Date>) -> Promise<[Category]> {
    realm.execute { realm in
      realm.objects(CategoryObject.self)
        .sorted(byKeyPath: "title")
        .map { categoryObject in
//          let rank = RankFactory.make(events: categoryObject.rawEvents, timeRange: timeRange)
          return ObservableCategoryObject(timeRange: timeRange, object: categoryObject)
        }
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

enum RankFactory {
  static func make<Events: Collection>(
    events: Events, timeRange: ClosedRange<Date>
  ) -> Rank where Events.Element == EventObject {
    let totalPoints = events.reduce(0, { $0 + $1.points })
    var currentMax = 10
    var pointsToNextLevel = currentMax

    var rank = 1
    var previousLevelPointCap = 0
    while pointsToNextLevel <= totalPoints {
      previousLevelPointCap = pointsToNextLevel
      currentMax *= 2
      pointsToNextLevel += currentMax
      rank += 1
    }

    let pointsInTimeWindow = events
      .filter { timeRange.contains($0.timestamp) }
      .map { $0.points }
      .reduce(0, +)
    let pointsInLevel = max(totalPoints - previousLevelPointCap - pointsInTimeWindow, 0)
    let pointsInTimeWindowToNextLevel = min(totalPoints - previousLevelPointCap, pointsInTimeWindow)

    return Rank(
      rank: rank,
      pointsInLevel: pointsInLevel,
      pointsInTimeWindow: pointsInTimeWindowToNextLevel,
      pointsToNextLevel: currentMax,
      totalPointsInTimeWindow: pointsInTimeWindow,
      totalPoints: totalPoints
    )
  }
}

//public class Points {
//
//  public static func startingRank() -> Rank {
//    return Rank(rank: 1, points: 0, pointsInTimeWindow: nil, pointsToNextLevel: 10, totalPoints: 0)
//  }
//
//  public static func rank(for totalPoints: Int) -> Rank {
//  }
//}
