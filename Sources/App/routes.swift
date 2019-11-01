import Vapor
import Authentication
import Crypto

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }

    // MARK: Authorization

    let basicAuthMiddleware = User.basicAuthMiddleware(using: BCrypt)
    let guardAuthMiddleware = User.guardAuthMiddleware()
    let basicAuthGroup = router.grouped([basicAuthMiddleware, guardAuthMiddleware])

    let authorizationController = UsersController()
    try authorizationController.boot(router: router)
    router.get("api", "users", "me", use: authorizationController.getUserInfo)

    // MARK: Line

    let tournamentsController = TournamentsController()
    router.get("api", "tournaments", use: tournamentsController.index)
    
    let gamesController = GamesController()
    router.get("api", "games") { req -> [String: GameInfo] in
        guard let ids = req.query[Array<String>.self, at: "ids"] else {
            throw Abort(.badRequest, reason: "No game exists with this ID." , identifier: nil)
        }
        return gamesController.getGamesInfo(ids: ids)
    }
    
    let eventsController = EventsController()
    router.get("api", "events", Int.parameter, String.parameter) { req -> EventLoopFuture<[Event]> in
        let tournamentID = try req.parameters.next(Int.self)
        let gameID = try req.parameters.next(String.self)
        return try eventsController.index(req, tournamentID: tournamentID, gameID: gameID)
    }

    let bettingController = BettingController()
    basicAuthGroup.post("api", "bets", use: bettingController.makeBet)
}

extension Bool: Content {}
