import Vapor
import FluentPostgreSQL

final class BettingController {
    func makeBet(_ req: Request) throws -> Future<Bet> {
        return try req.content.decode(Bet.self).flatMap { bet in
            return bet.save(on: req)
        }
    }
}
