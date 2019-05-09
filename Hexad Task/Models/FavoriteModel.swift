//
//  FavoriteModel.swift
//  Hexad Task
//
//  Created by Chieh Teng Wang on 07.05.19.
//  Copyright © 2019 Chieh Teng Wang. All rights reserved.
//

import Foundation

// Model for JSON
struct FavoriteModel: Codable {
    var favorites: [FavoriteItem]
    
    struct FavoriteItem: Codable {
        var title: String
        var rating: Int
    }
    func toFavorite() -> [Favorite] {
        return favorites.map {Favorite(identity: UUID().uuidString, title: $0.title, rating: $0.rating)}
    }
}
