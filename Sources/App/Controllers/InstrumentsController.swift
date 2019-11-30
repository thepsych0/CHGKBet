import Vapor
import FluentPostgreSQL

class InstrumentsController {
    func setAvailable(_ req: Request) -> Future<Int> {
        let query = Event.query(on: req)
            .join(\Tournament.id, to: \Event.tournamentID)
            .alsoDecode(Tournament.self)
            .all()
        return query.map { results -> Int in
            var completedCount = 0
            var newEvents = [Event]()
            for result in results {
                var event = result.0
                let tournament = result.1
                if Date().timeIntervalSince1970 > tournament.date {
                    if event.available {
                        completedCount += 1
                    }
                    event.available = false
                    newEvents.append(event)
                }
            }
            
            newEvents.forEach { $0.save(on: req) }
            return completedCount
        }
    }
    
    func returnLateBets(_ req: Request) -> Future<[String]> {
        let query = Bet.query(on: req)
            .join(\Event.id, to: \Bet.eventID)
            .alsoDecode(Event.self)
            .join(\Tournament.id, to: \Event.tournamentID)
            .alsoDecode(Tournament.self)
            .all()
        
        return query.flatMap { results -> Future<[String]> in
            var balanceChanges = [(user: User, change: Double)]()
            var descriptionsQueries = [Future<String>]()
            for result in results {
                var bet = result.0.0
                let tournament = result.1
                guard let betDate = bet.date else { throw Abort(.internalServerError, reason: "Bet without date.") }
                if betDate > tournament.date, let returned = bet.returned, !returned {
                    bet.returned = true
                    _ = bet.save(on: req)
                    let userQuery = User.query(on: req)
                        .filter(\User.id == bet.userID)
                        .first()
                    let desciptionQuery = userQuery.map { user -> String in
                        guard let newUser = user else {
                            throw Abort(.internalServerError, reason: "Invalid user ID.")
                        }
                        balanceChanges.append((user: newUser, change: bet.amount))
                        return "\(bet.amount) returned to \(newUser.email). User's balance was \(user?.infoWithID?.balance ?? 0) and now is \(newUser.infoWithID?.balance ?? 0). Bet was \"\(bet.selectedOptionTitle)\" on event  \"\(result.0.1.title)\"."
                    }
                    descriptionsQueries.append(desciptionQuery)
                }
            }
            let descriptionsQuery = descriptionsQueries.flatten(on: req)
            return descriptionsQuery.map { descriptions -> [String] in
                var newUsers = [User]()
                for balanceChange in balanceChanges {
                    if let i = newUsers.firstIndex(where: { $0.id == balanceChange.user.id }) {
                        newUsers[i].infoWithID?.balance += balanceChange.change
                    } else {
                        var newUser = balanceChange.user
                        newUser.infoWithID?.balance += balanceChange.change
                        newUsers.append(newUser)
                    }
                }
                _ = newUsers.forEach { $0.save(on: req) }
                return descriptions
            }
        }
    }
    
    
    
    func setSuccessForBets(_ req: Request) -> Future<(successCount: Int, failedCount: Int)> {
        let query = Bet.query(on: req)
            .join(\Event.id, to: \Bet.eventID)
            .alsoDecode(Event.self)
            .all()
        
        var successCount = 0
        var failedCount = 0
        
        return query.map { results -> (successCount: Int, failedCount: Int) in
            for result in results {
                var bet = result.0
                let event = result.1
                guard bet.success == nil, let eventSuccess = event.success else { return (successCount: 0, failedCount: 0) }
                bet.success = eventSuccess
                eventSuccess ? (successCount += 1) : (failedCount += 1)
            }
            
            return (successCount: successCount, failedCount: failedCount)
        }
    }
}
