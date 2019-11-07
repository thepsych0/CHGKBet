import Vapor
import FluentPostgreSQL

final class TournamentsController {
    func index(_ req: Request) throws -> Future<[Tournament]> {
        req.withPooledConnection(to: .psql) { connection -> Future<[Tournament]> in
            return Tournament.query(on: req).all()
        }
    }
}
