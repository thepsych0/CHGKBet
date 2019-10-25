import FluentPostgreSQL
import Vapor

final class Event: PostgreSQLModel {
    var id: Int?
    var title: String
    var options: [Option]

    init(id: Int? = nil, title: String, options: [Option]) {
        self.id = id
        self.title = title
        self.options = options
    }
}

extension Event: Migration { }
extension Event: Content { }
extension Event: Parameter { }

final class Option: PostgreSQLModel {
    var id: Int?
}

extension Option: Migration { }
extension Option: Content { }
extension Option: Parameter { }
