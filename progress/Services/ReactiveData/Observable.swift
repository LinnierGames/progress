import Combine

public enum ObservableErrors: Error {
  case objectDeleted
}

/// Put on public models like Person and Dog
public protocol Observable {
  var didChange: AnyPublisher<Void, ObservableErrors> { get }
}

/// Inherit this class on the Impl of public models like PersonImpl
open class ObservableBase: ObservableBaseHelper {
  public let objectWillChange = PassthroughSubject<Void, ObservableErrors>()
  public init() {}
}

public protocol ObservableBaseHelper {
}

/// Use these methods to notify the observer
extension ObservableBaseHelper where Self: ObservableBase {
  public func notifyIfNew<T: Equatable>(_ new: T, old: T) {
    guard new != old else { return }
    objectWillChange.send()
  }

  public func notify() {
    objectWillChange.send()
  }
}

/// Hook up the Observable publisher to the publisher provided by Combine.ObservableObject
extension ObservableBase: Observable {
  public var didChange: AnyPublisher<Void, ObservableErrors> {
    return objectWillChange.eraseToAnyPublisher()
  }
}

/// Conform to this on the Impl of public models like PersonImpl
public protocol ObservableBaseProtocol: ObservableBaseHelper {
  var objectDidChange: PassthroughSubject<Void, ObservableErrors> { get }
}

/// Use these methods to notify the observer
extension ObservableBaseHelper where Self: ObservableBaseProtocol {
  public func notifyIfNew<T: Equatable>(_ new: T, old: T) {
    guard new != old else { return }
    objectDidChange.send()
  }

  public func notify() {
    objectDidChange.send()
  }
}

extension ObservableBaseProtocol where Self: Observable {
  public var didChange: AnyPublisher<Void, ObservableErrors> {
    return objectDidChange.eraseToAnyPublisher()
  }
}
