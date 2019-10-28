import Vapor
import FluentPostgreSQL

struct Bet: PostgreSQLModel {
    var id: Int?
    var eventID: Int
    var selectedOptionTitle: String
    var amount: Double
    var success = false

    init(id: Int? = nil, eventID: Int, selectedOptionTitle: String, amount: Double) {
        self.id = id
        self.eventID = eventID
        self.selectedOptionTitle = selectedOptionTitle
        self.amount = amount
    }
}

extension Bet: Migration { }
extension Bet: Content { }
extension Bet: Parameter { }
