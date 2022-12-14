import Foundation

enum DisplayInfoPart: Equatable, CaseIterable {
    case breakfast
    case lunch
    case dinner
    case timeTable
}

extension DisplayInfoPart {
    var display: String {
        switch self {
        case .breakfast:
            return "π₯ μμΉ¨"
        case .lunch:
            return "π± μ μ¬"
        case .dinner:
            return "π μ λ"
        case .timeTable:
            return "β° μκ°ν"
        }
    }
}
