import Foundation
import Vapor
import Fluent
import FluentPostgreSQL
import Authentication

struct User: Content, PostgreSQLModel, Migration {
    var id: Int?
    private(set) var login: String
    private(set) var password: String
}

extension User: BasicAuthenticatable {
    static let usernameKey: WritableKeyPath<User, String> = \.login
    static let passwordKey: WritableKeyPath<User, String> = \.password
}
