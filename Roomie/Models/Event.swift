


import Foundation

import Foundation

struct Event {
    let id: String
    let date: Date
    let note: String
}

//struct Event: Identifiable {
//    enum EventType: String, Identifiable, CaseIterable {
//        case work, home, social, sport, unspecified
//        var id: String {
//            self.rawValue
//        }
//
//        var icon: String {
//            switch self {
//            case .work:
//                return "🏦"
//            case .home:
//                return "🏡"
//            case .social:
//                return "🎉"
//            case .sport:
//                return "🏟"
//            case .unspecified:
//                return "📌"
//            }
//        }
//    }
//
//    var eventType: EventType
//    var date: Date
//    var note: String
//    var id: String
//    
//    var dateComponents: DateComponents {
//        var dateComponents = Calendar.current.dateComponents(
//            [.month,
//             .day,
//             .year,
//             .hour,
//             .minute],
//            from: date)
//        dateComponents.timeZone = TimeZone.current
//        dateComponents.calendar = Calendar(identifier: .gregorian)
//        return dateComponents
//    }
//
//    init(id: String = UUID().uuidString, eventType: EventType = .unspecified, date: Date, note: String) {
//        self.eventType = eventType
//        self.date = date
//        self.note = note
//        self.id = id
//    }
//
//    // Data to be used in the preview
//    static var sampleEvents: [Event] {
//        return [
//            Event(eventType: .home, date: Date().addingTimeInterval(86400), note: "Take dog to groomers"),
//            Event(date: Date().addingTimeInterval(86400 * 2), note: "Get gift for Emily"),
//            Event(eventType: .home, date: Date().addingTimeInterval(-(86400 * 2)), note: "File tax returns."),
//            Event(eventType: .social, date: Date().addingTimeInterval(86400 * 3), note: "Dinner party at Dave and Janet's"),
//            Event(eventType: .work, date: Date().addingTimeInterval(-(86400 * 4)), note: "Complete Audit."),
//            Event(eventType: .sport, date: Date().addingTimeInterval(86400 * 5), note: "Football Game"),
//            Event(date: Date().addingTimeInterval(86400 * 2), note: "Plan for winter vacation.")
//        ]
//    }
//}
