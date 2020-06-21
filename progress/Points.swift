import Foundation

class Points {
  struct Rank {
    let points: Int
    let pointsToNextLevel: Int
    let rank: Int

    func display() -> String {
      return "lvl \(self.rank)"
    }
  }

  static func rank(for points: Int) -> Rank {
    var currentMax = 10

    var rank = 1
    while currentMax < points {
      currentMax *= 2
      rank += 1
    }

    return Rank(points: points, pointsToNextLevel: currentMax, rank: rank)
  }
}

class Category {
  let title: String
  var events = [Event]()

  init(title: String) {
    self.title = title
  }
}

extension Category {
  var points: Int {
    return events.reduce(0, { $0 + $1.points })
  }
}

class Event {
  let title: String
  let points: Int
  let timestamp: Date

  init(title: String, points: Int,  timestamp: Date) {
    self.title = title
    self.points = points
    self.timestamp = timestamp
  }
}
