import Vapor
import FluentPostgreSQL

struct PlayerInfo: Content {
    let ratingData: RatingResponse?
    let balance: Double?
}
