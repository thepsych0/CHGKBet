import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }

    let tournamentsController = TournamentsController()
    router.get("api", "tournaments", use: tournamentsController.index)
    
    let gamesController = GamesController()
    router.get("api", "games") { req -> [String: GameInfo] in
        guard let ids = req.query[Array<String>.self, at: "id"] else {
            throw Abort(.badRequest, reason: "No game exists with this ID." , identifier: nil)
        }
        return gamesController.getGamesInfo(ids: ids)
    }

    let userRouteController = UserController()
    try userRouteController.boot(router: router)
}
