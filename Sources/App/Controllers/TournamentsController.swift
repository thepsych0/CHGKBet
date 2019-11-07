import Vapor
import FluentPostgreSQL

final class TournamentsController {
    func index(_ req: Request) throws -> [Tournament] {
        return ServerModels.tournaments
    }
}

final class ServerModels {
    static let tournaments = [Tournament(id: 1, title: "MGIMO-International", date: 1573285500, games: ["chgk","brainNoF","ek","si","other"])]
}
