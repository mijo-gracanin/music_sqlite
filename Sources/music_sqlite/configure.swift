import NIOSSL
import Fluent
import FluentSQLiteDriver
import Leaf
import Vapor
import QueuesRedisDriver

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)
    
    app.migrations.add(CreateTrack())
    
    app.views.use(.leaf)
    
    try app.queues.use(.redis(url: "redis://127.0.0.1:6379"))
    app.queues.add(DownloadJob())
    try app.queues.startInProcessJobs(on: .default)
//    try app.queues.startScheduledJobs()
    app.http.server.configuration.hostname = "0.0.0.0" // Default is 127.0.0.1 but than it's not reachable from another device
    
    // register routes
    try routes(app)
}

let pathToM4AFiles = "/Users/mgracanin/YouTube/"
