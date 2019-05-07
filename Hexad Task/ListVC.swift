//
//  ListVC.swift
//  Hexad Task
//
//  Created by Chieh Teng Wang on 07.05.19.
//  Copyright © 2019 Chieh Teng Wang. All rights reserved.
//

import UIKit

class ListVC: UITableViewController {
    var favorites: [FavoriteModel.FavoriteItem] = []
    
    // MARK: - IBActions
    @IBAction func randomRatingPressed(_ sender: Any) {
    }
    
    // MARK: - View Events
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        fetchData()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
        cell.title.text = favorites[indexPath.row].title
        for (index, img) in cell.ratings.arrangedSubviews.enumerated() {
            img.isHidden = (index + 1) > favorites[indexPath.row].rating
        }
        return cell
    }
}

// MARK: - Private Helpers
private extension ListVC {
    func fetchData() {
        let path = Bundle.main.path(forResource: "Favorite", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        
        do {
            let data = try Data(contentsOf: url)
            let result = try JSONDecoder().decode(FavoriteModel.self, from: data)
            self.favorites = result.favorites
        } catch let error {
            print("Fetch json data error: \(error)")
        }
    }

}
