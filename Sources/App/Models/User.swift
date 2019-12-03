import Foundation
import Vapor
import Fluent
import FluentPostgreSQL
import Authentication

struct User: Content, PostgreSQLModel, Migration {
    var id: Int?
    private(set) var email: String
    private(set) var password: String
    var ratingID: String? {
        didSet {
            guard let ratingID = ratingID else { return }
            info?.ratingURL = "https://rating.chgk.info/player/\(ratingID)"
        }
    }
    private var info: UserInfo?
    var infoWithID: UserInfo? {
        get {
            var newInfo = info
            newInfo?.id = id
            return newInfo
        } set {
            info = newValue
        }
    }
    var latestOS: String?
    var latestDevice: String?
    var latestVersion: String?

    init(id: Int? = nil, email: String, password: String, ratingID: String? = nil, info: UserInfo? = nil) {
        self.id = id
        self.email = email
        self.password = password
        self.ratingID = ratingID
        self.info = info
    }
}

extension User: BasicAuthenticatable {
    static let usernameKey: WritableKeyPath<User, String> = \.email
    static let passwordKey: WritableKeyPath<User, String> = \.password
}

struct UserInfo: Content, PostgreSQLModel, Migration {
    var id: Int?
    var ratingURL: String?
    var ratingData: RatingResponse?
    var balance: Double
    var betIDs: [Int]
    var bets: [BetHistory]?
}
