import Foundation
import Vapor
import Fluent
import Crypto

class UsersController: RouteCollection {
    func boot(router: Router) throws {
        let group = router.grouped("api", "users")
        group.post(User.self, at: "register", use: registerUserHandler)
    }

    func getUserInfo(_ req: Request) throws -> UserInfo {
        let user = try req.requireAuthenticated(User.self)
        guard let userInfo = user.info else { throw Abort(.badRequest) }
        return userInfo
    }
}

//MARK: Helper
private extension UsersController {

    func registerUserHandler(_ request: Request, newUser: User) throws -> Future<HTTPResponseStatus> {
        return User.query(on: request).filter(\.login == newUser.login).first().flatMap { existingUser in
            guard existingUser == nil else {
                throw Abort(.badRequest, reason: "A user with this login already exists." , identifier: nil)
            }

            let tournaments = Tournament.query(on: request).all()
            return tournaments.flatMap { tournaments -> Future<HTTPResponseStatus> in
                let isInPeriod = tournaments.filter { tournament in
                    let difference = Date(timeIntervalSince1970: tournament.date).timeIntervalSince1970 - Date().timeIntervalSince1970
                    return difference > 0 && difference < tournamentPeriodInSeconds
                }.isEmpty

                let digest = try request.make(BCryptDigest.self)
                let hashedPassword = try digest.hash(newUser.password)
                let balance: Double = isInPeriod ? baseBalance + tournamentBalance : baseBalance
                let persistedUser = User(
                    id: nil,
                    login: newUser.login,
                    password: hashedPassword,
                    ratingID: newUser.ratingID,
                    info: UserInfo(
                        id: nil,
                        ratingURL: newUser.ratingID,
                        balance: balance,
                        betHistory: []
                    )
                )

                return persistedUser.save(on: request).transform(to: .created)
            }
        }
    }
}

private let tournamentPeriodInSeconds: Double = 7 * 24 * 60 * 60
private let baseBalance: Double = 1000
private let tournamentBalance: Double = 500
