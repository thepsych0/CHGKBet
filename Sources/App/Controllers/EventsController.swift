import Vapor
import FluentPostgreSQL

final class EventsController {
    func index(_ req: Request, tournamentID: Int, gameID: String) throws -> Future<[Event]> {
        return Event.query(on: req).all()
    }
}
