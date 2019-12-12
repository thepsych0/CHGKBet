import Vapor
import FluentPostgreSQL

struct Bet: PostgreSQLModel {
    var id: Int?
    var eventID: Int
    var userID: Int? = nil
    var selectedOptionTitle: String
    var amount: Double
    var success: Bool? = false
    var date: Double?
    var returned: Bool?
    var counted: Bool? = false
    var payoff: Double? = 0

    init(id: Int? = nil, eventID: Int, selectedOptionTitle: String, amount: Double) {
        self.id = id
        self.eventID = eventID
        self.selectedOptionTitle = selectedOptionTitle
        self.amount = amount
    }
}

struct BetHistory: Content {
    let id: Int?
    let selectedOptionTitle: String
    let amount: Double
    let success: Bool
    let date: Double
    let tournament: Tournament
    let event: Event

    init(bet: Bet, tournament: Tournament, event: Event) {
        self.id = bet.id
        self.selectedOptionTitle = bet.selectedOptionTitle
        self.amount = bet.amount
        self.success = bet.success ?? false
        self.date = bet.date ?? 0
        self.tournament = tournament
        self.event = event
    }
}

extension Bet: Migration { }
extension Bet: Content { }
extension Bet: Parameter { }
