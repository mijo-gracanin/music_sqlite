//
//  Track.swift
//  music_sqlite
//
//  Created by Mijo Gracanin on 02.04.2025..
//
import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final class Track: Model, @unchecked Sendable {
    static let schema = "tracks"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "source_url")
    var sourceUrl: String
    
    @Field(key: "name")
    var name: String

    init() { }

    init(id: UUID? = nil, sourceUrl: String, name: String = "") {
        self.id = id
        self.name = name
        self.sourceUrl = sourceUrl
    }
    
    func toDTO() -> TrackDTO {
        .init(
            id: self.id,
            sourceUrl: self.$sourceUrl.value,
            name: self.$name.value
        )
    }
}
