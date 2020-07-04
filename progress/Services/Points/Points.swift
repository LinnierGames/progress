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
