import Foundation

public class Points {
  public struct Rank {
    public let rank: Int
    public let points: Int
    public let pointsToNextLevel: Int
    public let totalPoints: Int

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

    public func display() -> String {
      return "lvl \(self.rank)"
    }
  }

  public static func startingRank() -> Rank {
    return Rank(rank: 1, points: 0, pointsToNextLevel: 10, totalPoints: 0)
  }

  public static func rank(for totalPoints: Int) -> Rank {
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

public protocol Category {
  var title: String { get }
  var events: [Event] { get }
  var rewards: [Reward] { get }

//  init(title: String) {
//    self.title = title
//  }
}

extension Category {
  public var points: Int {
    return events.reduce(0, { $0 + $1.points })
  }
}

public protocol Event {
  var title: String { get }
  var points: Int { get }
  var timestamp: Date { get }

//  init(title: String, points: Int,  timestamp: Date) {
//    self.title = title
//    self.points = points
//    self.timestamp = timestamp
//  }
}

public protocol Reward {
  var title: String { get }
  var points: Int { get }
  var isOneTimeReward: Bool { get }
}
