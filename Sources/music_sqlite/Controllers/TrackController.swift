//
//  TrackController.swift
//  music_sqlite
//
//  Created by Mijo Gracanin on 01.04.2025..
//
import Fluent
import Vapor

struct TrackController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let tracks = routes.grouped("tracks")

        tracks.get(use: self.index)
        tracks.post(use: self.create)
        tracks.delete(use: self.deleteAll)
        tracks.group(":trackID") { track in
            track.get(use: self.getM4A)
            track.delete(use: self.delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [TrackDTO] {
        return try await Track.query(on: req.db).all().map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> TrackDTO {
        let track = try req.content.decode(TrackDTO.self).toModel()

        try await track.save(on: req.db)
        let trackDTO = track.toDTO()
        
        try await req.queue.dispatch(DownloadJob.self, trackDTO)
        guard let downloadedTrack = try await Track.find(track.id, on: req.db) else {
            throw Abort(.notFound)
        }
        return downloadedTrack.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let track = try await Track.find(req.parameters.get("trackID"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await track.delete(on: req.db)
        return .noContent
    }
    
    @Sendable
    func deleteAll(req: Request) async throws -> HTTPStatus {
        try await Track.query(on: req.db).delete(force: true)
        return .noContent
    }
    
    @Sendable
    func getM4A(req: Request) async throws -> Response {
        guard let track = try await Track.find(req.parameters.get("trackID"), on: req.db) else {
            throw Abort(.notFound)
        }
        let res = try await req.fileio.asyncStreamFile(at: pathToM4AFiles + track.name + ".m4a")
        return res
    }
}
