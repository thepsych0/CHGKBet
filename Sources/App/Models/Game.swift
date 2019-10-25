import Vapor

enum Game: String {
    case chgk
    case brain
    case si
    case ek

    private var title: String {
        switch self {
        case .brain:
            return "Брейн-ринг"
        case .chgk:
            return "Что? Где? Когда?"
        case .si:
            return "Своя игра"
        case .ek:
            return "Эрудит-квартет"
        }
    }

    var gameInfo: GameInfo {
        return GameInfo(title: title)
    }
}

struct GameInfo {
    let title: String
}
