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

    let userRouteController = UserController()
    try userRouteController.boot(router: router)
}
