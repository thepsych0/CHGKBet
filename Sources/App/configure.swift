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
        dbConfig = PostgreSQLDatabaseConfig(url: "postgres://tbbahuxiiktnso:516fcc2af6165c87bb724eea1aae51cc1759203e5a59e6126d7e9f89bc541c07@ec2-54-220-0-91.eu-west-1.compute.amazonaws.com:5432/dv6a1uqbbflbf", transport: .unverifiedTLS)!
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

    let poolConfig = DatabaseConnectionPoolConfig(maxConnections: 2)
    services.register(poolConfig)
}

extension Environment {
    var type: EnvironmentType? {
        return EnvironmentType(rawValue: name)
    }

    enum EnvironmentType: String {
        case development
        case production
    }
}
