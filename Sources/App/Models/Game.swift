import Vapor

enum Game: String {
    case chgk
    case brain
    case brainNoF
    case si
    case ek

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
        }
    }
    
    private var info: String? {
        switch self {
        case .brainNoF:
            return "Без фальстартов"
        default:
            return nil
        }
    }

    var gameInfo: GameInfo {
        return GameInfo(title: title, info: info)
    }
}

struct GameInfo: Content {
    let title: String
    let info: String?
}
