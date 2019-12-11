import Vapor
import Authentication
import Crypto

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req -> String in
        let env = try! Environment.detect()
        print(req.http.headers[.host])
        return "\(env.name), \(req.http.headers[.host]))"
    }

    // MARK: Apps

    let appsController = AppsController()
    router.get("api", "get-versions", use: appsController.getVersion)

    router.get("install-ios") { req -> Future<View> in
        return try appsController.getApp(req, os: .iOS)
    }
    router.get("install-android") { req -> Future<View> in
        return try appsController.getApp(req, os: .android)
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
    router.get("api", "events", Int.parameter, String.parameter) { req -> Future<[Event]> in
        let tournamentID = try req.parameters.next(Int.self)
        let gameID = try req.parameters.next(String.self)
        return try eventsController.index(req, tournamentID: tournamentID, gameID: gameID)
    }

    let bettingController = BettingController()
    basicAuthGroup.post("api", "bets", use: bettingController.makeBet)
    
    // MARK: Top
    
    basicAuthGroup.get("api", "top", use: usersController.topPlayers)

    // MARK: FAQ
    
    let faqController = FAQController()
    router.get("api", "faq", use: faqController.getFAQ)
    
    // MARK: Instruments
    
    let instrumentsController = InstrumentsController()
    router.get("instruments", "set-available", use: instrumentsController.setAvailable)
    router.get("instruments", "return-late-bets", use: instrumentsController.returnLateBets)
    router.get("instruments", "set-success-for-bets", use: instrumentsController.setSuccessForBets)
    router.get("instruments", "count-users-balances", use: instrumentsController.countUsersBalances)
}

extension Bool: Content {}
