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

class ListVC: UITableViewController {
    let disposeBag = DisposeBag()
    let favorites: BehaviorRelay<[FavoriteModel.FavoriteItem]> = BehaviorRelay(value: [])
    
    // MARK: - IBActions
    @IBAction func randomRatingPressed(_ sender: Any) {
        
    }
    
    // MARK: - View Events
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        bindTableView()
        fetchData()
    }
}

// MARK: - ListCellOutput
extension ListVC: ListCellOutput {
    func rateDidPress(cell: ListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        print(indexPath.row)
    }
}

// MARK: - Private Helpers
private extension ListVC {
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
            self.favorites.accept(result.favorites)
        } catch let error {
            print("Fetch json data error: \(error)")
        }
    }

}
