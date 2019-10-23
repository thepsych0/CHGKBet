import FluentSQLite
import Vapor

final class Tournament: SQLiteModel {
    var id: Int?
    var title: String
    var date: Double

    init(id: Int? = nil, title: String, date: Double) {
        self.id = id
        self.title = title
        self.date = date
    }
}

extension Tournament: Migration { }
extension Tournament: Content { }
extension Tournament: Parameter { }
