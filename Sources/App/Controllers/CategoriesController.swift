import Vapor
import FluentMySQL

final class CategoriesController {
    func index(_ req: Request) throws -> Future<[Category]> {
        return Category.query(on: req).all()
    }
}
