import Vapor
import FluentPostgreSQL

final class EventsController {
    func index(_ req: Request, tournamentID: Int, gameID: String) throws -> Future<[Event]> {
        //handbrake
        let query = Event.query(on: req)
            .filter(\Event.tournamentID == tournamentID)
            .filter(\Event.gameID == gameID)
            .all()
        return query.map { events -> [Event] in
            return events.filter { $0.tournamentID == 1 }
        }
    }
}
