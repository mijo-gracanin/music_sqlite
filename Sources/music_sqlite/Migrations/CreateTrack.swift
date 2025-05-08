import Fluent

struct CreateTrack: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("tracks")
            .id()
            .field("source_url", .string, .required)
            .field("name", .string, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("tracks").delete()
    }
}
