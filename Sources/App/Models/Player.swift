import Vapor
import FluentPostgreSQL

struct PlayerInfo: Content {
    let name: String
    let balance: Double
}
