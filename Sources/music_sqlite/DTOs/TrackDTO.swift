//
//  TrackDTO.swift
//  music_sqlite
//
//  Created by Mijo Gracanin on 02.04.2025..
//
import Fluent
import Vapor

struct TrackDTO: Content {
    var id: UUID?
    var sourceUrl: String?
    var name: String?
    
    func toModel() -> Track {
        let model = Track()
        
        model.id = id
        if let sourceUrl = self.sourceUrl {
            model.sourceUrl = sourceUrl
        }
        model.name = name ?? ""

        return model
    }
}
