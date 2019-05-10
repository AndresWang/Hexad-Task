//
//  ListInteractor.swift
//  Hexad Task
//
//  Created by Chieh Teng Wang on 10.05.19.
//  Copyright © 2019 Chieh Teng Wang. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

typealias Section = AnimatableSectionModel<String, FavoriteViewModel>
typealias CurrentRating = Int
protocol ListInteractorDelegate {
    func fetchData()
    func bindTableView(_ dataSource: RxTableViewSectionedAnimatedDataSource<Section>, _ tableView: UITableView)
    func setTimer()
    func cancelTimer()
    func userDidSelectAnItemToRate(index: Int) -> CurrentRating
    func userDidFinishRating(newRating: Int)
}

// Note: Interactor is our business logic, which serves as a coordinator to get works done in cooperation with other services such as data store and api, etc.
class ListInteractor: ListInteractorDelegate {
    let favorites: BehaviorRelay<[Section]> = BehaviorRelay(value: [])
    let disposeBag = DisposeBag()
    var selectedID: String?
    var timer: Timer?
    
    // MARK: - ListInteractorDelegate
    func fetchData() {
        let favorites = DataStore.shared.fetchData().map {$0.toViewModel()}
        let sortedFavorites = favorites.sorted {$0.rating > $1.rating}
        self.favorites.accept([Section(model: "", items: sortedFavorites)])
    }
    func bindTableView(_ dataSource: RxTableViewSectionedAnimatedDataSource<Section>,_ tableView: UITableView) {
        favorites
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    func setTimer() {
        // Create and configure the timer for random intervals
        let randInterval = Double.random(in: 1...10)
        timer = Timer.scheduledTimer(timeInterval: randInterval, target: self, selector: #selector(randomRating), userInfo: nil, repeats: false)
        // Optimize the timer for increased power savings and responsiveness
        timer?.tolerance = randInterval / 2
        // Helps UI stay responsive even with timer.
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
    }
    func cancelTimer() {
        timer?.invalidate()
    }
    func userDidSelectAnItemToRate(index: Int) -> CurrentRating {
        let selectedItem = section.items[index]
        self.selectedID = selectedItem.identity
        return selectedItem.rating
    }
    func userDidFinishRating(newRating: Int) {
        guard let index = section.items.firstIndex(where: {$0.identity == selectedID}) else {return}
        updateRating(newRating, at: index)
        self.selectedID = nil
    }
}

private extension ListInteractor {
    var section: Section {
        // We only have 1 section
        return favorites.value[0]
    }
    @objc func randomRating() {
        let randRating = Int.random(in: 1...5)
        let randIndex = Int.random(in: 0..<section.items.count)
        updateRating(randRating, at: randIndex)
        
        // Set timer to keep it going
        setTimer()
    }
    func updateRating(_ newRating: Int, at index: Int) {
        var items = section.items
        items[index].rating = newRating
        items.sort{ $0.rating > $1.rating }
        favorites.accept([Section(model: "", items: items)])
    }
}
