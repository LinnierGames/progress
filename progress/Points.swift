import Foundation

class Points {
  struct Rank {
    let rank: Int
    let points: Int
    let pointsToNextLevel: Int
    let totalPoints: Int

    fileprivate init(
      rank: Int,
      points: Int,
      pointsToNextLevel: Int,
      totalPoints: Int
    ) {
      self.rank = rank
      self.points = points
      self.pointsToNextLevel = pointsToNextLevel
      self.totalPoints = totalPoints
    }

    func display() -> String {
      return "lvl \(self.rank)"
    }
  }

  static func startingRank() -> Rank {
    return Rank(rank: 1, points: 0, pointsToNextLevel: 10, totalPoints: 0)
  }

  static func rank(for totalPoints: Int) -> Rank {
    var currentMax = 10, pointsToNextLevel = currentMax

    var rank = 1
    var previousLevelPointCap = 0
    while pointsToNextLevel <= totalPoints {
      previousLevelPointCap = pointsToNextLevel
      currentMax *= 2
      pointsToNextLevel += currentMax
      rank += 1
    }
    let points = totalPoints - previousLevelPointCap

    return Rank(
      rank: rank,
      points: points,
      pointsToNextLevel: currentMax,
      totalPoints: totalPoints
    )
  }
}

protocol Category {
  var title: String { get }
  var events: [Event] { get }

//  init(title: String) {
//    self.title = title
//  }
}

extension Category {
  var points: Int {
    return events.reduce(0, { $0 + $1.points })
  }
}

protocol Event {
  var title: String { get }
  var points: Int { get }
  var timestamp: Date { get }

//  init(title: String, points: Int,  timestamp: Date) {
//    self.title = title
//    self.points = points
//    self.timestamp = timestamp
//  }
}
