import FluentMySQL
import Vapor

final class Category: MySQLModel {
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
