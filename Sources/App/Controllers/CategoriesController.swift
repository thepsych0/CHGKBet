import Vapor
import FluentPostgreSQL

final class CategoriesController {
    func index(_ req: Request) throws -> Future<[Category]> {
        return Category.query(on: req).all()
    }
}
