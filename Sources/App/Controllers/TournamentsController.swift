import Vapor
import FluentPostgreSQL

final class TournamentsController {
    func index(_ req: Request) throws -> Future<[Tournament]> {
        let query = Tournament.query(on: req).all()
        return query.map { tournaments -> [Tournament] in
            let env = try! Environment.detect()
            print(env.name)
            tournaments.forEach { $0.logoURL = "\(env.type!.serverAddress)/logo/tournaments/\($0.id!).png" }
            return tournaments
        }
    }
}
