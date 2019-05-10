//
//  DataStore.swift
//  Hexad Task
//
//  Created by Chieh Teng Wang on 10.05.19.
//  Copyright © 2019 Chieh Teng Wang. All rights reserved.
//

import Foundation

class DataStore {
    static let shared = DataStore()
    private init(){}
    
    // MARK: Boundary Methods
    func fetchData() -> [Favorite.FavoriteItem] {
        let path = Bundle.main.path(forResource: "Favorite", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        
        do {
            let data = try Data(contentsOf: url)
            let result = try JSONDecoder().decode(Favorite.self, from: data)
            return result.favorites
        } catch let error {
            print("Fetch json data error: \(error)")
            return []
        }
    }
}
