//
//  Favorite.swift
//  Hexad Task
//
//  Created by Chieh Teng Wang on 07.05.19.
//  Copyright © 2019 Chieh Teng Wang. All rights reserved.
//

import Foundation

// Model for JSON
struct Favorite: Codable {
    var favorites: [FavoriteItem]
    
    struct FavoriteItem: Codable {
        var title: String
        var rating: Int
        func toViewModel() -> FavoriteViewModel {
            return FavoriteViewModel(identity: UUID().uuidString, title: title, rating: rating)
        }
    }
}
