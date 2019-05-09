//
//  ListVC.swift
//  Hexad Task
//
//  Created by Chieh Teng Wang on 07.05.19.
//  Copyright © 2019 Chieh Teng Wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Cosmos

class ListVC: UITableViewController {
    // MARK: - Properties
    let disposeBag = DisposeBag()
    let favorites: BehaviorRelay<[FavoriteModel.FavoriteItem]> = BehaviorRelay(value: [])
    let ratingViewTag = 200
    var ratingIndex: Int?
    
    // MARK: - IBOutlets
    @IBOutlet var ratingView: UIView!
    @IBOutlet var cosmosView: CosmosView!
    
    // MARK: - IBActions
    @IBAction func submitPressed(_ sender: Any) {
        dismissRatingView()
    }
    @IBAction func randomRatingPressed(_ sender: Any) {
        
    }
    
    // MARK: - View Events
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        bindTableView()
        fetchData()
    }
}

// MARK: - ListCellOutput
extension ListVC: ListCellOutput {
    func rateDidPress(cell: ListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        self.ratingIndex = indexPath.row
        showRatingView(rating: favorites.value[indexPath.row].rating)
    }
}

// MARK: - Private Helpers
private extension ListVC {
    func config() {
        tableView.rowHeight = UITableView.automaticDimension
        ratingView.translatesAutoresizingMaskIntoConstraints = false
        ratingView.tag = ratingViewTag
    }
    func bindTableView() {
        tableView.dataSource = nil
        favorites.bind(to: tableView.rx.items(cellIdentifier: "ListCell", cellType: ListCell.self)) { row, item, cell in
            cell.config(item: item, output: self)
            }.disposed(by: disposeBag)
    }
    func fetchData() {
        let path = Bundle.main.path(forResource: "Favorite", ofType: "json")
        let url = URL(fileURLWithPath: path!)

        do {
            let data = try Data(contentsOf: url)
            let result = try JSONDecoder().decode(FavoriteModel.self, from: data)
            self.favorites.accept(result.favorites.sorted {$0.rating > $1.rating})
        } catch let error {
            print("Fetch json data error: \(error)")
        }
    }
    func showRatingView(rating: Int) {
        guard let navView = navigationController?.view else { return }
        cosmosView.rating = Double(rating)
        navigationController?.view.addSubview(ratingView)
        NSLayoutConstraint.activate([
            ratingView.heightAnchor.constraint(equalToConstant: 140),
            ratingView.widthAnchor.constraint(equalToConstant: 180),
            ratingView.centerXAnchor.constraint(equalTo: navView.centerXAnchor),
            ratingView.centerYAnchor.constraint(equalTo: navView.centerYAnchor)
        ])
    }
    func dismissRatingView() {
        guard let index = ratingIndex else {return}
        let rating = Int(cosmosView.rating)
        var favoriteArray = favorites.value
        favoriteArray[index].rating = rating
        favorites.accept(favoriteArray)
        ratingView.removeFromSuperview()
        self.ratingIndex = nil
    }
}
