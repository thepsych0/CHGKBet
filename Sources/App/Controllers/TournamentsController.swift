import Vapor
import FluentSQLite

final class TournamentsController {
    func index(_ req: Request) throws -> Future<[Tournament]> {
        return Tournament.query(on: req).all()
    }

    func create(_ req: Request) throws -> Future<Tournament> {
        return try req.content.decode(Tournament.self).flatMap { tournament in
            return tournament.save(on: req)
        }
    }
}
