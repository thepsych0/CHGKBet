import FluentPostgreSQL
import Vapor

final class Category: PostgreSQLModel {
    var id: Int?
    var title: String

    init(id: Int? = nil, title: String) {
        self.id = id
        self.title = title
    }
}

extension Category: Migration { }
extension Category: Content { }
extension Category: Parameter { }
