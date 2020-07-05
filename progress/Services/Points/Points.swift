
public struct Rank {
  public let rank: Int
  public let pointsInLevel: Int
  public let pointsInTimeWindow: Int
  public let pointsToNextLevel: Int
  public let totalPoints: Int

  public func display() -> String {
    return "lvl \(self.rank)"
  }
}
