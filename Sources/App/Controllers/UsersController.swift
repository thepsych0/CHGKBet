import Foundation
import Vapor
import Fluent
import Crypto

class UsersController: RouteCollection {
    
    private let tournamentPeriodInSeconds: Double = 7 * 24 * 60 * 60
    private let baseBalance: Double = 2000
    private let tournamentBalance: Double = 500
    
    //MARK: Auth
    
    func boot(router: Router) throws {
        let group = router.grouped("api", "users")
        group.post(User.self, at: "register", use: registerUserHandler)
    }
    
    func getUserInfo(_ req: Request) throws -> Future<UserInfo> {
        var user = try req.requireAuthenticated(User.self)
        guard let osString = req.http.headers.firstValue(name: HTTPHeaderName("os")),
        let os = AppOS(rawValue: osString),
        let device = req.http.headers.firstValue(name: HTTPHeaderName("device")),
        let version = req.http.headers.firstValue(name: HTTPHeaderName("version")) else {
            throw Abort(.badRequest)
        }
        user.latestOS = os.rawValue
        user.latestDevice = device
        user.latestVersion = version
        _ = user.save(on: req)
        guard var userInfo = user.infoWithID else { throw Abort(.badRequest) }
        let query = Bet.query(on: req)
            .filter(\Bet.userID == user.id)
            .join(\Event.id, to: \Bet.eventID)
            .alsoDecode(Event.self)
            .join(\Tournament.id, to: \Event.tournamentID)
            .alsoDecode(Tournament.self)
            .all()
        return query.map { results in
            let betHistory = results.map { BetHistory(bet: $0.0.0, tournament: $0.1, event: $0.0.1) }
            userInfo.bets = betHistory
            return userInfo
        }
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
    
    func setRatingID(req: Request, id: String) throws -> Future<UserInfo> {
        var user = try req.requireAuthenticated(User.self)
        let users = User.query(on: req)
            .filter(\User.ratingID == id)
            .all()
        return users.flatMap { [weak self] usersWithGivenRatingID -> Future<UserInfo> in
            guard let self = self else { throw Abort(.internalServerError, reason: "Unknown error.") }
            guard usersWithGivenRatingID.isEmpty else { throw Abort(.badRequest, reason: "User with this rating ID already exists.") }
            user.ratingID = id
            return try self.checkRatingID(req: req, id: id).flatMap { ratingResponse -> Future<UserInfo> in
                user.infoWithID?.ratingData = ratingResponse
                user.infoWithID?.ratingData?.id = id
                return user.save(on: req).map { savedUser -> UserInfo in
                    return user.infoWithID!
                }
            }
        }
    }
    
    // MARK: Top
    
    func topPlayers(_ req: Request) throws -> Future<[PlayerInfo]> {
        let user = try req.requireAuthenticated(User.self)
        let usersQuery = User.query(on: req).all()

        return usersQuery.map { topUsers -> [PlayerInfo] in
            return topUsers
                .sorted { $0.infoWithID?.balance ?? 0 < $1.infoWithID?.balance ?? 0}
                .compactMap { player in
                    guard player.id != nil, let balance = player.infoWithID?.balance else { return nil }
                    return PlayerInfo(name: player.id == user.id ? "Я" : "Кто-то", balance: balance)
                    //return PlayerInfo(name: player.email, balance: balance)
                }
                .suffix(11)
                .reversed()
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
            let tournamentsQuery = Tournament.query(on: request).all()

            return tournamentsQuery.flatMap { [weak self] tournaments -> Future<UserInfo> in
                guard let self = self else { throw Abort(.internalServerError, reason: "Unknown error.") }
                let nearbyTournaments = tournaments.filter { tournament in
                    let difference = Date(timeIntervalSince1970: tournament.date).timeIntervalSince1970 - Date().timeIntervalSince1970
                    return difference > 0 && difference < self.tournamentPeriodInSeconds
                }
                let isInPeriod = !nearbyTournaments.isEmpty
                
                let digest = try request.make(BCryptDigest.self)
                let hashedPassword = try digest.hash(newUser.password)
                let balance: Double = isInPeriod ? self.tournamentBalance + self.baseBalance : self.baseBalance
                let persistedUser = User(
                    id: nil,
                    email: newUser.email,
                    password: hashedPassword,
                    ratingID: newUser.ratingID,
                    info: UserInfo(
                        id: nil,
                        ratingURL: newUser.ratingID,
                        balance: balance,
                        betIDs: []
                    )
                )
                
                return persistedUser.save(on: request).map { savedUser -> UserInfo in
                    return savedUser.infoWithID!
                }
            }
        }
    }
}

struct RatingResponse: Content {
    var id: String?
    var name: String?
    var patronymic: String?
    var surname: String?
}
