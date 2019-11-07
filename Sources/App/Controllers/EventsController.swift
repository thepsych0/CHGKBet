import Vapor
import FluentPostgreSQL

final class EventsController {
    func index(_ req: Request, tournamentID: Int, gameID: String) throws -> Future<[Event]> {
        req.withPooledConnection(to: .psql) { connection -> EventLoopFuture<[Event]> in
            return Event.query(on: req)
            .filter(\Event.tournamentID == tournamentID)
            .filter(\Event.gameID == gameID)
            .all()
        }

    }
}
