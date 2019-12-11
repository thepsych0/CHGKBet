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
                    if event.isAvailable {
                        completedCount += 1
                    }
                    event.isAvailable = false
                    newEvents.append(event)
                }
            }
            
            newEvents.forEach { _ = $0.save(on: req) }
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
                newUsers.forEach { _ = $0.save(on: req) }
                return descriptions
            }
        }
    }
    
    
    
    func setSuccessForBets(_ req: Request) -> Future<SuccessSettingResults> {
        let query = Bet.query(on: req)
            .join(\Event.id, to: \Bet.eventID)
            .alsoDecode(Event.self)
            .all()
        
        var successCount = 0
        var failedCount = 0

        var betsToSave = [Bet]()
        
        return query.map { results -> SuccessSettingResults in
            for result in results {
                var bet = result.0
                let event = result.1
                guard bet.success == nil,
                    let eventOptionSuccess = event.options.first(where: { $0.title == bet.selectedOptionTitle })?.success
                    else { continue }
                bet.success = eventOptionSuccess
                betsToSave.append(bet)
                eventOptionSuccess ? (successCount += 1) : (failedCount += 1)
            }

            betsToSave.forEach { _ = $0.save(on: req) }
            
            return .init(successCount: successCount, failedCount: failedCount)
        }
    }

    func countUsersBalances(_ req: Request) -> Future<[Double]> {
        let betQuery = Bet.query(on: req)
            .join(\Event.id, to: \Bet.eventID)
            .alsoDecode(Event.self)
            .all()
        let query = betQuery.and(User.query(on: req).all())

        return query.map { results -> [Double] in
            for betAndEvent in results.0 {
                let bet = betAndEvent.0
                if bet.success ?? false {
                    guard !bet.counted else { continue }
                    let user = results.1.first(where: { $0.id == bet.userID } )
                    guard var userUnwrapped = user else {
                        _ = bet.delete(on: req)
                        continue
                    }
                    guard let option = betAndEvent.1.options.first(where: { $0.title == bet.selectedOptionTitle }),
                        let coef = option.coef
                        else { continue }
                    userUnwrapped.infoWithID?.balance += bet.amount * coef
                    _ = userUnwrapped.save(on: req)
                }
            }

            return results.1.compactMap { $0.infoWithID?.balance }
        }
    }
}

struct SuccessSettingResults: Content {
    let successCount: Int
    let failedCount: Int
}
