import UIKit

extension UIAlertController {
  func insertTextField(_ config: ((UITextField) -> Void)? = nil) -> UITextField {
    var tf: UITextField! = nil
    let _: Void = self.addTextField { textField in
      config?(textField)
      tf = textField
    }

    return tf
  }
}

extension String {
  func useIfEmpty(_ string: String) -> String {
    guard self.isEmpty == false else { return string }
    return self
  }
}

extension Optional where Wrapped == String {
  func useIfEmptyOrNil(_ string: String) -> String {
    guard let self = self else { return string }
    return self.useIfEmpty(string)
  }
}

extension Date {
  var midnight: Date {
    let calendar = Calendar.current
    return calendar.startOfDay(for: self)
    var components = calendar.dateComponents([.calendar, .timeZone, .month, .day, .year, .hour, .minute, .second], from: self)
    components.hour = 0
    components.minute = 0
    components.second = 0

    return components.date!
  }

  var endOfDay: Date {
    let calendar = Calendar.current
    var components = calendar.dateComponents([.calendar, .timeZone, .month, .day, .year, .hour, .minute, .second], from: self)
    components.hour = 23
    components.minute = 59
    components.second = 59

    return components.date!
  }

  var startOfWeek: Date {
    let gregorian = Calendar.current
    let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
    return gregorian.date(byAdding: .day, value: 1, to: sunday)!
  }

  var endOfWeek: Date {
    let gregorian = Calendar.current
    let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
    return gregorian.date(byAdding: .day, value: 7, to: sunday)!
//    let calendar = Calendar.current
//    var startOfTheWeek: NSDate?
//    var endOfWeek: NSDate!
//    var interval: TimeInterval = 0
//
//    calendar.range
//    calendar.rangeOfUnit(.WeekOfMonth, startDate: &startOfTheWeek, interval: &interval, forDate: NSDate())
//    endOfWeek = startOfTheWeek!.dateByAddingTimeInterval(interval - 1)
  }
}

extension TimeInterval {
  init(minutes: Int) {
    self = TimeInterval(minutes) * 60
  }

  init(hours: Int) {
    self = TimeInterval(hours) * TimeInterval(minutes: 60)
  }

  init(days: Int) {
    self = TimeInterval(days) * TimeInterval(hours: 24)
  }

  init(weeks: Int) {
    self = TimeInterval(weeks) * TimeInterval(days: 7)
  }
}
