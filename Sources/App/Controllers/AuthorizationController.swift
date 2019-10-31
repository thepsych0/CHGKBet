import Foundation
import Vapor
import Fluent
import Crypto

class AuthorizationController: RouteCollection {
    func boot(router: Router) throws {
        let group = router.grouped("api", "users")
        group.post(User.self, at: "register", use: registerUserHandler)
    }

    func authorize(_ req: Request) throws -> HTTPResponseStatus {
        _ = try req.requireAuthenticated(User.self)
        return .ok
    }
}

//MARK: Helper
private extension AuthorizationController {

    func registerUserHandler(_ request: Request, newUser: User) throws -> Future<HTTPResponseStatus> {
        return User.query(on: request).filter(\.login == newUser.login).first().flatMap { existingUser in
            guard existingUser == nil else {
                throw Abort(.badRequest, reason: "A user with this email already exists." , identifier: nil)
            }

            let digest = try request.make(BCryptDigest.self)
            let hashedPassword = try digest.hash(newUser.password)
            let persistedUser = User(id: nil, login: newUser.login, password: hashedPassword)

            return persistedUser.save(on: request).transform(to: .created)
        }
    }
}
