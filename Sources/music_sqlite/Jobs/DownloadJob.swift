//
//  DownloadJob.swift
//  music_sqlite
//
//  Created by Mijo Gracanin on 02.04.2025..
//
import Vapor
import Foundation
import Queues

struct DownloadJob: AsyncJob {
    
    typealias Payload = TrackDTO

    func dequeue(_ context: QueueContext, _ payload: TrackDTO) async throws {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/Users/mgracanin/.local/bin/yt-dlp")
        task.arguments = [
            "--ffmpeg-location",
            "/opt/homebrew/bin/ffmpeg",
            "--extract-audio",
            "--audio-format",
            "m4a",
            "-o",
            #"~/YouTube/%(title)s.%(ext)s"#,
            payload.sourceUrl!]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        try task.run()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        
        let output = String(decoding: outputData, as: UTF8.self)
        let error = String(decoding: errorData, as: UTF8.self)
        
        if !error.isEmpty {
            print(error)
        }
        
        let name = try extractFileName(from: output)
        
        guard let track = try await Track.find(payload.id, on: context.application.db) else {
            throw Abort(.notFound)
        }
        track.name = name
        try await track.save(on: context.application.db)
    }
    
    func extractFileName(from string: String) throws -> String {
        let regex = /YouTube\/(?<name>.+?)\.m4a/
        guard let result = try regex.firstMatch(in: string) else {
            throw MusicAppError.failedToExtractTrackName
        }
        return String(result.name)
    }
}
