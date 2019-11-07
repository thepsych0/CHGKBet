import Vapor
import FluentPostgreSQL

final class TournamentsController {
    func index(_ req: Request) throws -> Future<[Tournament]> {
        return Tournament.query(on: req).all()
    }
}
