import FluentPostgreSQL
import Vapor

final class Tournament: PostgreSQLModel {
    var id: Int?
    var title: String
    var date: Double
    var games: [String]
    var gamesEnum: [Game] {
        let tempGames = games.compactMap { Game(rawValue: $0) }
        return tempGames.count == games.count ? tempGames : []
    }
    var logoURL: String?

    init(id: Int? = nil, title: String, date: Double, games: [String]) {
        self.id = id
        self.title = title
        self.date = date
        self.games = games
    }
}

extension Tournament: Migration { }
extension Tournament: Content { }
extension Tournament: Parameter { }
