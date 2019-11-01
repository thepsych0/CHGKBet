import Foundation
import Vapor
import Fluent
import FluentPostgreSQL
import Authentication

struct User: Content, PostgreSQLModel, Migration {
    var id: Int?
    private(set) var login: String
    private(set) var password: String
    var ratingID: String? {
        didSet {
            guard let ratingID = ratingID else { return }
            info?.ratingURL = "https://rating.chgk.info/player/\(ratingID)"
        }
    }
    var info: UserInfo?
}

extension User: BasicAuthenticatable {
    static let usernameKey: WritableKeyPath<User, String> = \.login
    static let passwordKey: WritableKeyPath<User, String> = \.password
}

struct UserInfo: Content, PostgreSQLModel, Migration {
    var id: Int?
    var ratingURL: String?
    var balance: Double
    var betHistory: [Bet]
}
