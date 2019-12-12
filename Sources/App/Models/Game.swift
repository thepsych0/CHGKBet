import Vapor

enum Game: String {
    case chgk
    case brain
    case brainNoF
    case si
    case ek
    case other
    case chgkSt
    case ekSt
    case siSt

    private var title: String {
        switch self {
        case .brain, .brainNoF:
            return "Брейн-ринг"
        case .chgk, .chgkSt:
            return "Что? Где? Когда?"
        case .si, .siSt:
            return "Своя игра"
        case .ek, .ekSt:
            return "Эрудит-квартет"
        case .other:
            return "Другое"
        }
    }
    
    private var info: String? {
        switch self {
        case .brainNoF:
            return "Без фальстартов"
        case .other:
            return "События, не привязанные к конкретной игре"
        case .chgkSt, .siSt, .ekSt:
            return "Студенческий зачёт"
        default:
            return nil
        }
    }

    var gameInfo: GameInfo {
        return GameInfo(id: rawValue, title: title, additionalInfo: info)
    }
}

struct GameInfo: Content {
    let id: String
    let title: String
    let additionalInfo: String?
}
