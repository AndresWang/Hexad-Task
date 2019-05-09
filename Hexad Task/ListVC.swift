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
import RxDataSources
import Cosmos

typealias Section = AnimatableSectionModel<String, Favorite>

class ListVC: UITableViewController {
    // MARK: - Properties
    let disposeBag = DisposeBag()
    let ratingViewTag = 200
    var ratingIndex: Int?
    let favorites: BehaviorRelay<[Section]> = BehaviorRelay(value: [])
    
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
        fetchData()
        bindTableView()
    }
}
// MARK: - ListCellOutput
extension ListVC: ListCellOutput {
    func rateDidPress(cell: ListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        self.ratingIndex = indexPath.row
        showRatingView(rating: section.items[indexPath.row].rating)
    }
}

// MARK: - Private Helpers
private extension ListVC {
    var section: Section {
        // We only have 1 section
        return favorites.value[0]
    }
    func config() {
        tableView.rowHeight = UITableView.automaticDimension
        ratingView.translatesAutoresizingMaskIntoConstraints = false
        ratingView.tag = ratingViewTag
    }
    func fetchData() {
        let path = Bundle.main.path(forResource: "Favorite", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        
        do {
            let data = try Data(contentsOf: url)
            let result = try JSONDecoder().decode(FavoriteModel.self, from: data)
            let sortedFavorites = result.toFavorite().sorted {$0.rating > $1.rating}
            self.favorites.accept([Section(model: "", items: sortedFavorites)])
        } catch let error {
            print("Fetch json data error: \(error)")
        }
    }
    func bindTableView() {
        tableView.dataSource = nil
        let dataSource = RxTableViewSectionedAnimatedDataSource<Section>(
            configureCell: { _, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
                cell.config(item: item, output: self)
                return cell
        })
        favorites
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
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
        var favoriteArray = favorites.value[0].items
        favoriteArray[index].rating = rating
        favoriteArray.sort{ $0.rating > $1.rating }
        favorites.accept([Section(model: "", items: favoriteArray)])
        ratingView.removeFromSuperview()
        self.ratingIndex = nil
    }
}
