import Vapor
import FluentPostgreSQL

final class EventsController {
    func index(_ req: Request, tournamentID: Int, gameID: String) throws -> [Event] {
        return ServerModels.events.filter { $0.tournamentID == tournamentID && $0.gameID == gameID }
    }
}
