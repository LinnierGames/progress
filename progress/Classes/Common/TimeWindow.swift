import Foundation

struct TimeWindow {
  enum WindowSize: CaseIterable {
    case day
    case threeDays
    case week
    case month
    case year

    var display: String {
      switch self {
      case .day: return "Day"
      case .threeDays: return "Three Days"
      case .week: return "Week"
      case .month: return "Month"
      case .year: return "Year"
      }
    }
  }
  private(set) var window: ClosedRange<Date>
  var windowSize: WindowSize {
    didSet {
      window = TimeWindow.computeBounds(windowSize: windowSize, referenceDate: window.upperBound)
    }
  }

  init(windowSize: WindowSize) {
    self.windowSize = windowSize
    let today = Date()
    self.window = TimeWindow.computeBounds(windowSize: windowSize, referenceDate: today)
  }

  static func computeBounds(
    windowSize: TimeWindow.WindowSize, referenceDate: Date
  ) -> ClosedRange<Date> {
    let oneDay: TimeInterval = 60 * 60 * 24
    switch windowSize {
    case .day:
      return referenceDate.midnight...referenceDate.endOfDay
    case .threeDays:
      return referenceDate.addingTimeInterval(oneDay * -3).midnight...referenceDate.endOfDay
    case .week:
      return referenceDate.startOfWeek...referenceDate.endOfWeek
    default:
      fatalError()
      break
    }
  }

  mutating func nextWindow() {
    slideWindow(forward: true)
  }

  mutating func previousWindow() {
    slideWindow(forward: false)
  }

  private mutating func slideWindow(forward: Bool) {
    let offset: (Date, TimeInterval) -> Date = { date, adjustment in
      date + (adjustment * (forward ? 1 : -1))
    }
    switch windowSize {
    case .day:
      window =
        (offset(window.lowerBound, TimeInterval(days: 1)))
        ...
        (offset(window.upperBound, TimeInterval(days: 1)))
    case .threeDays:
      window =
        (offset(window.lowerBound, TimeInterval(days: 3)))
        ...
        (offset(window.upperBound, TimeInterval(days: 3)))
    case .week:
      window =
        (offset(window.lowerBound, TimeInterval(weeks: 1)))
        ...
        (offset(window.upperBound, TimeInterval(weeks: 1)))
    default:
      fatalError()
    }
  }
}
