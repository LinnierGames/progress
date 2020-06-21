//
//  DataLayer.swift
//  progress
//
//  Created by Erick Sanchez on 6/20/20.
//  Copyright © 2020 Erick Sanchez. All rights reserved.
//

import Foundation



protocol Group {
}
protocol Category {
  var name: String { get }
}
protocol Event {
}
protocol Reward {
}

protocol GroupStore {
}

protocol CatergoryStore {
}

import Promises

func injectProgressService() -> ProgressService {
  return ProgressServiceImpl()
}
protocol ProgressService {
//  func progress() -> AnyLiveQuery<Progress>

  // MARK: Group

//  func saveGroup(name: String) -> Promise<Group>

  // MARK: Category

  func categories(for group: Group?) -> AnyLiveQuery<Category>
  func saveCategory(name: String, into group: Group?) -> Promise<Category>

  // MARK: Events

//  func saveEvent(name: String, points: Int, to category: Category) -> Promise<Event>

  // MARK: Rewards

//  func saveReward(name: String, pointValue: Int, to category: Category) -> Promise<Reward>
}

struct Group_Realm: Group {
  var name = "hahah"
}

struct Category_Realm: Category {
  var name = "hahah1"
  init() {}
  init(_ name: String) {
    self.name = name
  }
}

class ProgressServiceImpl: ProgressService {
  func categories(for group: Group?) -> AnyLiveQuery<Category> {

  }

  func saveCategory(name: String, into group: Group?) -> Promise<Category> {
    return Promise { resolve, reject in
      resolve(Category_Realm())
    }
  }
}

protocol LiveQueryDelegate {
  func didChange()
}

protocol LiveQuery: AnyObject, Collection {
//  func didChange()
  var delegate: LiveQueryDelegate? { get set }
}

class PrivateLiveQuery: LiveQuery {
  var delegate: LiveQueryDelegate?

}

class AnyLiveQuery<T>: LiveQuery, LiveQueryDelegate where Element == T {
  private let source: T

  var delegate: LiveQueryDelegate?

//  init<G: LiveQuery>(sourceQuery: G) where G.Element == T {
  init<G: LiveQuery>(sourceQuery: G) where G.Element == T {
    self.source = sourceQuery
    sourceQuery.delegate = self
  }

//  typealias Element = T.Element
//  typealias Index = T.Index

  var startIndex: Index { return source.startIndex }
  var endIndex: Index { return source.endIndex }

  subscript(index: T.Index) -> T.Element {
    return source[index]
  }

  func index(after index: T.Index) -> T.Index {
    return source.index(after: index)
  }

  // MARK: LiveQueryDelegate

  func didChange() {
    self.delegate?.didChange()
  }
}

import RealmSwift

class Cat: RealmSwift.Object {
}

class RealmLiveQuery: LiveQuery {
  var delegate: LiveQueryDelegate?

  init() {
    Realm().objects(Cat.self).observe { (_) in
      self.delegate?.didChange()
    }
  }

  var startIndex: Int { return <#collection#>.startIndex }
  var endIndex: Int { return <#collection#>.endIndex }

  subscript(index: Int) -> <#collection type#> {
    return <#collection#>[index]
  }

  func index(after index: Int) -> Index {
    return <#collection#>.index(after: index)
  }
}
