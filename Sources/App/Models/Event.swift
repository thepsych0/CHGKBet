import FluentPostgreSQL
import Vapor

struct Event: PostgreSQLModel {
    var id: Int?
    var title: String
    var options: [Option]
    let gameID: String
    let tournamentID: Int
    var isAvailable: Bool

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
        self.isAvailable = available
    }
}

extension Event: Migration { }
extension Event: Content { }
extension Event: Parameter { }

struct Option: PostgreSQLModel {
    var id: Int?
    var title: String?
    var coef: Double?
    var success: Bool?
}

extension Option: Migration { }
extension Option: Content { }
extension Option: Parameter { }
