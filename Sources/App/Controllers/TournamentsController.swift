import Vapor
import FluentPostgreSQL

final class TournamentsController {
    func index(_ req: Request) throws -> Future<[Tournament]> {
        let query = Tournament.query(on: req).all()
        return query.map { tournaments -> [Tournament] in
            tournaments.forEach { $0.logoURL = "https://chgkbet-develop.vapor.cloud/logo/tournaments/\($0.id!).png" }
            return tournaments
        }
    }
}
