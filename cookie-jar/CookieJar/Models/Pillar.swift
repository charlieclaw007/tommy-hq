import Foundation

/// The four fixed daily promises. Order is fixed and user-facing everywhere.
enum Pillar: String, CaseIterable, Identifiable, Codable {
    case diet
    case gym
    case phone
    case sleep

    var id: String { rawValue }

    var letter: String {
        switch self {
        case .diet: return "D"
        case .gym: return "G"
        case .phone: return "P"
        case .sleep: return "S"
        }
    }

    var title: String {
        switch self {
        case .diet: return "Diet"
        case .gym: return "Gym"
        case .phone: return "Phone"
        case .sleep: return "Sleep"
        }
    }

    var defaultRule: String {
        switch self {
        case .diet: return "Ate the way I intended"
        case .gym: return "Moved my body"
        case .phone: return "Kept screen time in check"
        case .sleep: return "Protected my rest"
        }
    }
}
