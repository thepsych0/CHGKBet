import FluentPostgreSQL
import Vapor

struct Event: PostgreSQLModel {
    var id: Int?
    var title: String
    var options: [Option]
    let gameID: String
    let tournamentID: Int

    init(id: Int? = nil, title: String, options: [Option], gameID: String, tournamentID: Int) {
        self.id = id
        self.title = title
        self.options = options
        self.gameID = gameID
        self.tournamentID = tournamentID
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
