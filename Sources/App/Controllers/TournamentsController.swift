import Vapor
import FluentPostgreSQL

final class TournamentsController {
    func index(_ req: Request) throws -> Future<[Tournament]> {
        let query = Tournament.query(on: req).all()
        return query.map { tournaments -> [Tournament] in
            let env = try! Environment.detect()
            tournaments.forEach {
                if let serverAddress = env.type?.serverAddress, let id = $0.id {
                    $0.logoURL = "\(serverAddress)/logo/tournaments/\(id).png"
                }
                $0.isOver = $0.date <= Date().timeIntervalSince1970
            }
            return tournaments.sorted(by: { $0.date > $1.date })
        }
    }
}
