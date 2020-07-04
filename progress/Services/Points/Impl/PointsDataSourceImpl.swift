import Foundation
import RealmSwift
import Promises
import ReactiveData

class PointsDataSourceImpl: PointsDataSource {
  let realm = RealmExecutor()

  func categories() -> Promise<[Category]> {
    realm.execute { realm in
      realm.objects(CategoryObject.self)
        .sorted(byKeyPath: "title")
        .map { $0 as Category }
    }
  }

  func createCategory(title: String) -> Promise<Void> {
    realm.execute { realm in
      try realm.write {
        let newCategory = CategoryObject()
        newCategory.title = title
        realm.add(newCategory)
      }
    }
  }

  func createEvent(title: String, points: Int, category: Category) -> Promise<Void> {
    guard let categoryObject = category as? CategoryObject else { return Promise {} }
    return realm.execute { realm in
      try realm.write {
        let newEvent = EventObject()
        newEvent.points = points
        newEvent.title = title
        newEvent.timestamp = Date()
        newEvent.category = categoryObject
        categoryObject.rawEvents.append(newEvent)
        realm.add(newEvent)
      }
    }
  }
}





