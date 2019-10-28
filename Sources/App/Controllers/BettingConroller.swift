import Vapor
import FluentPostgreSQL

final class BettingController {
    func makeBet(_ req: Request) throws -> Future<HTTPResponseStatus> {
        let user = try req.requireAuthenticated(User.self)


        return try req.content.decode(Bet.self).flatMap { bet in

            let events = Event.query(on: req)
                .filter(\Event.id == bet.eventID)
                .all()

            return events.flatMap { events -> Future<HTTPResponseStatus> in
                if events.isEmpty {
                    throw Abort(.badRequest, reason: "Incorrect event ID." , identifier: nil)
                } else if !events.first!.options.contains(where: { $0.title == bet.selectedOptionTitle }) {
                    throw Abort(.badRequest, reason: "Incorrect option title." , identifier: nil)
                } else {
                    var betWithUserID = Bet(id: bet.id, eventID: bet.eventID, selectedOptionTitle: bet.selectedOptionTitle, amount: bet.amount)
                    betWithUserID.userID = user.id
                    return betWithUserID.save(on: req).transform(to: .created)
                }
            }
        }
    }
}
