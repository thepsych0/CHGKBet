import FluentPostgreSQL
import Vapor
import Authentication
import Leaf

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())
    try services.register(LeafProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a PostgreSQL database
    let dbConfig: PostgreSQLDatabaseConfig
//    if let type = env.type, type == .production {
        dbConfig = PostgreSQLDatabaseConfig(url: "postgres://bcffjvjvkgeosf:f4ffc55ea016d9393dcf64b5228543cc0d5a6916cc234650c79fb741559cbaef@ec2-54-228-250-82.eu-west-1.compute.amazonaws.com:5432/d3hgolk8rdq88d", transport: .unverifiedTLS)!
//    } else {
//        config = PostgreSQLDatabaseConfig(hostname: "localhost", port: 5432, username: "thepsych0", database: "chgkbet", password: nil, transport: .cleartext)
//    }
    let postgres = PostgreSQLDatabase(config: dbConfig)

    // Register the configured PostgreSQL database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: postgres, as: .psql)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Tournament.self, database: .psql)
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Event.self, database: .psql)
    migrations.add(model: Bet.self, database: .psql)
    services.register(migrations)

    config.prefer(LeafRenderer.self, for: ViewRenderer.self)

    let poolConfig = DatabaseConnectionPoolConfig(maxConnections: 3)
    services.register(poolConfig)
}

extension Environment {
    var type: EnvironmentType? {
        return EnvironmentType(rawValue: name)
    }

    enum EnvironmentType: String {
        case develop
        case production

        var serverAddress: String {
            switch self {
            case .production:
                return "https://chgk-bet.herokuapp.com"
            case .develop:
                return "https://chgk-bet.herokuapp.com"
            }
        }
    }
}
