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

            var balanceChanges = [(user: User, change: Double, betID: Int)]()
            for betAndEvent in results.0 {
                let bet = betAndEvent.0
                if bet.success ?? false {
                    guard let counted = bet.counted, !counted else { continue }
                    let user = results.1.first(where: { $0.id == bet.userID } )
                    guard let userUnwrapped = user else {
                        _ = bet.delete(on: req)
                        continue
                    }
                    guard let option = betAndEvent.1.options.first(where: { $0.title == bet.selectedOptionTitle }),
                        let coef = option.coef
                        else { continue }
                    balanceChanges.append((user: userUnwrapped, change: bet.amount * coef, betID: bet.id!))
                    var newBet = bet
                    newBet.counted = true
                    newBet.payoff = bet.amount * coef
                    _ = newBet.save(on: req)
                } else {
                    var newBet = bet
                    newBet.counted = true
                    _ = newBet.save(on: req)
                }
            }

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

            return newUsers.compactMap { $0.infoWithID?.balance }
        }
    }

    func addMoneyToEveryAccount(req: Request, sum: Double) -> Future<[Double]> {
        User.query(on: req).all().flatMap { users -> Future<[Double]> in
            let queries = users.map { user -> Future<User> in
                var newUser: User = user
                newUser.infoWithID?.balance += sum
                return newUser.save(on: req)
            }
            let query = queries.flatten(on: req)
            return query.map { users -> [Double] in
                return users.map { $0.infoWithID?.balance ?? -1 }
            }
        }
    }
}

//let betQuery = Bet.query(on: req)
//    .join(\Event.id, to: \Bet.eventID)
//    .alsoDecode(Event.self)
//    .all()
//let query = betQuery.and(User.query(on: req).all())
//
//return query.map { results -> [Double] in
//
//    let ownedBetIDs = results.1.map { $0.infoWithID!.betIDs }
//    let flatOwnedBetIDs = ownedBetIDs.flatMap { $0 }
//    let bets = results.0.map { $0.0 }
//    return bets.filter { !flatOwnedBetIDs.contains($0.id!) }.map { Double($0.id!) }



struct SuccessSettingResults: Content {
    let successCount: Int
    let failedCount: Int
}
