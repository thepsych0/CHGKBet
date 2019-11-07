import Vapor

enum Game: String {
    case chgk
    case brain
    case brainNoF
    case si
    case ek
    case other

    private var title: String {
        switch self {
        case .brain, .brainNoF:
            return "Брейн-ринг"
        case .chgk:
            return "Что? Где? Когда?"
        case .si:
            return "Своя игра"
        case .ek:
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
