// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "CHGKBet",
    products: [
        .library(name: "CHGKBet", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0-rc"),
        .package(url: "https://github.com/vapor/crypto.git", from: "3.0.0"),

        // 🐘 Non-blocking, event-driven Swift client for PostgreSQL.
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),

        // leaf
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentPostgreSQL", "Vapor", "Authentication", "Crypto", "Leaf"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

