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
    router.get("api", "games", String.parameter) { req -> GameInfo in
        let gameID = try req.parameters.next(String.self)
        if let gameInfo = gamesController.getGameInfo(id: gameID) {
            return gameInfo
        } else {
            throw Abort(.badRequest, reason: "No game exists with this ID." , identifier: nil)
        }
    }

    let userRouteController = UserController()
    try userRouteController.boot(router: router)
}
