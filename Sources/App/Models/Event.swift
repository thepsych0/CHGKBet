import FluentPostgreSQL
import Vapor

struct Event: PostgreSQLModel {
    var id: Int?
    var title: String
    var options: [Option]
    let gameID: String
    let tournamentID: Int
    var available: Bool
    var success: Bool?
    var state: State {
        if available {
            return .available
        } else {
            if let success = success {
                return success ? .passed : .failed
            } else {
                return .waiting
            }
        }
    }
    
    enum State: String {
        case passed
        case failed
        case available
        case waiting
    }

    init(
        id: Int? = nil,
        title: String,
        options: [Option],
        gameID: String,
        tournamentID: Int,
        available: Bool,
        success: Bool?
    ) {
        self.id = id
        self.title = title
        self.options = options
        self.gameID = gameID
        self.tournamentID = tournamentID
        self.available = available
        self.success = success
    }
}

extension Event: Migration { }
extension Event: Content { }
extension Event: Parameter { }

struct Option: PostgreSQLModel {
    var id: Int?
    var title: String?
    var coef: Double?
}

extension Option: Migration { }
extension Option: Content { }
extension Option: Parameter { }
