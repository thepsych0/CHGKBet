import Vapor
import Authentication
import Crypto

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }

    //let websiteController = WebsiteController()
    //try router.register(collection: websiteController)

    router.get("install-ios") { req -> Future<View> in
      return try req.view().render("install-ios")
    }

    router.get("install-android") { req -> Future<View> in
      return try req.view().render("install-android")
    }

    // MARK: Users

    let basicAuthMiddleware = User.basicAuthMiddleware(using: BCrypt)
    let guardAuthMiddleware = User.guardAuthMiddleware()
    let basicAuthGroup = router.grouped([basicAuthMiddleware, guardAuthMiddleware])

    let usersController = UsersController()
    try usersController.boot(router: router)
    basicAuthGroup.get("api", "users", "me", use: usersController.getUserInfo)
    basicAuthGroup.post("api", "users", "rating", "setID", String.parameter) {req -> Future<UserInfo> in
        let id = try req.parameters.next(String.self)
        return try usersController.setRatingID(req: req, id: id)
    }
    router.get("api", "users", "rating", "checkID", String.parameter) { req -> Future<RatingResponse> in
        let id = try req.parameters.next(String.self)
        return try usersController.checkRatingID(req: req, id: id)
    }

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
    
    // MARK: Top
    
    router.get("api", "top", use: usersController.topPlayers)

    // MARK: FAQ
    let faqController = FAQController()
    router.get("api", "faq", use: faqController.getFAQ)
}

extension Bool: Content {}
