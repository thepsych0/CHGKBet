import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }

    let tournamentsController = TournamentsController()
    router.get("api", "tournaments", use: tournamentsController.index)

    let userRouteController = UserController()
    try userRouteController.boot(router: router)
}
