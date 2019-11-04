import Vapor
import FluentPostgreSQL

final class BettingController {
    func makeBet(_ req: Request) throws -> Future<HTTPResponseStatus> {
        var user = try req.requireAuthenticated(User.self)
        guard user.infoWithID != nil else { throw Abort(.internalServerError) }


        return try req.content.decode(Bet.self).flatMap { bet in

            let events = Event.query(on: req)
                .filter(\Event.id == bet.eventID)
                .all()

            return events.flatMap { events -> Future<HTTPResponseStatus> in
                guard !events.isEmpty else { throw Abort(.badRequest, reason: "Incorrect event ID.") }
                guard events.first!.options.contains(where: { $0.title == bet.selectedOptionTitle }) else {
                    throw Abort(.badRequest, reason: "Incorrect option title.")
                }
                guard bet.amount > 0 else { throw Abort(.badRequest, reason: "Bet amount should be greater than 0.") }
                guard bet.amount <= user.infoWithID?.balance ?? 0 else { throw Abort(.badRequest, reason: "You don't have enough funds.") }

                var betWithUserID = Bet(id: bet.id, eventID: bet.eventID, selectedOptionTitle: bet.selectedOptionTitle, amount: bet.amount)
                betWithUserID.userID = user.id
                user.infoWithID!.balance -= bet.amount
                user.infoWithID!.betHistory.append(bet)
                let saveBet = betWithUserID.save(on: req)
                let saveUser = user.save(on: req)
                return saveBet.and(saveUser).transform(to: .created)
            }
        }
    }
}
