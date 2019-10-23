import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }

    let tournamentsController = TournamentsController()
    router.get("tournaments", use: tournamentsController.index)

    let categoriesController = CategoriesController()
    router.get("tournaments", Int.parameter, "categories", use: categoriesController.index)
    //router.post("tournaments", use: tournamentsController.create)
}
