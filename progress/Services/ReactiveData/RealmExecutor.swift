import Foundation
import RealmSwift
import Promises

public class RealmExecutor {

  var realm: Realm?

  public init() {}

  @discardableResult
  public func execute<T>(_ block: @escaping (Realm) throws -> T) -> Promise<T> {
    do {
      let realm: Realm
      if let selfRealm = self.realm {
        realm = selfRealm
      } else {
        realm = try Realm()
        self.realm = realm
      }

      return Promise {
        return try block(realm)
      }
    } catch {
      return Promise<T>(error)
    }
  }
}
