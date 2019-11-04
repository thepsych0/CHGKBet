import Foundation
import Vapor
import Fluent
import Crypto

class UsersController: RouteCollection {
    
    //MARK: Auth
    
    func boot(router: Router) throws {
        let group = router.grouped("api", "users")
        group.post(User.self, at: "register", use: registerUserHandler)
    }

    func getUserInfo(_ req: Request) throws -> UserInfo {
        let user = try req.requireAuthenticated(User.self)
        guard let userInfo = user.info else { throw Abort(.badRequest) }
        return userInfo
    }

    //MARK: Rating

    func checkRatingID(req: Request, id: String) throws -> Future<RatingResponse> {

        let client = try req.client()
        let response = client.get("https://rating.chgk.info/api/players/\(id)")

        let users = User.query(on: req)
            .filter(\User.ratingID == id)
            .all()

        return response
            .and(users)
            .flatMap { res -> Future<RatingResponse> in
                guard res.1.isEmpty else { throw Abort(.badRequest, reason: "User with this rating ID already exists.") }
                let ratingResponse = try res.0.content.decode(json: [RatingResponse].self, using: JSONDecoder())
                return ratingResponse.map { players in
                    guard let player = players.first else { throw Abort(.locked) }
                    return player
                }
            }
    }

    func setRatingID(_ req: Request) throws -> Future<HTTPResponseStatus> {
        var user = try req.requireAuthenticated(User.self)
        guard let ratingID = req.query[String.self, at: "id"] else {
            throw Abort(.badRequest, reason: "Parameter \"ratingID\" is required." , identifier: nil)
        }
        let users = User.query(on: req)
            .filter(\User.ratingID == ratingID)
            .all()
        return users.flatMap { [weak self] usersWithGivenRatingID -> Future<HTTPResponseStatus> in
            guard let self = self else { throw Abort(.internalServerError, reason: "Unknown error.") }
            guard usersWithGivenRatingID.isEmpty else { throw Abort(.badRequest, reason: "User with this rating ID already exists.") }
            user.ratingID = ratingID
            return try self.checkRatingID(req: req, id: ratingID).flatMap { ratingResponse -> Future<HTTPResponseStatus> in
                user.info?.ratingData = ratingResponse
                return user.save(on: req).transform(to: .created)
            }
        }
    }
    
    // MARK: Top
    
    func topUsers(_ req: Request) throws -> Future<[[String: Double]]> {
        let users = User.query(on: req)
            .filter(\User.ratingID != nil)
            .sort(\User.info?.balance)
            .range(..<10)
            .all()
        
        return users.map { topUsers -> [[String: Double]] in
            return topUsers.map { [$0.email: $0.info?.balance ?? 0] }
        }
    }
}

//MARK: Helper
private extension UsersController {

    func registerUserHandler(_ request: Request, newUser: User) throws -> Future<UserInfo> {
        guard newUser.email.isValidEmail else { throw Abort(.badRequest, reason: "Email is invalid.") }
        return User.query(on: request).filter(\.email == newUser.email).first().flatMap { existingUser in
            guard existingUser == nil else {
                throw Abort(.badRequest, reason: "A user with this login already exists.")
            }

            let tournaments = Tournament.query(on: request).all()
            return tournaments.flatMap { tournaments -> Future<UserInfo> in
                let isInPeriod = tournaments.filter { tournament in
                    let difference = Date(timeIntervalSince1970: tournament.date).timeIntervalSince1970 - Date().timeIntervalSince1970
                    return difference > 0 && difference < tournamentPeriodInSeconds
                }.isEmpty

                let digest = try request.make(BCryptDigest.self)
                let hashedPassword = try digest.hash(newUser.password)
                let balance: Double = isInPeriod ? baseBalance + tournamentBalance : baseBalance
                let persistedUser = User(
                    id: nil,
                    email: newUser.email,
                    password: hashedPassword,
                    ratingID: newUser.ratingID,
                    info: UserInfo(
                        id: nil,
                        ratingURL: newUser.ratingID,
                        balance: balance,
                        betHistory: []
                    )
                )

                return persistedUser.save(on: request).transform(to: persistedUser.info!)
            }
        }
    }
}

private let tournamentPeriodInSeconds: Double = 7 * 24 * 60 * 60
private let baseBalance: Double = 1000
private let tournamentBalance: Double = 500

struct RatingResponse: Codable, Content {
    var name: String?
    var patronymic: String?
    var surname: String?
}
