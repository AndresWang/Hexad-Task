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

// Note: For a real app the interactor normally will talk with a seperated dataStore service, and most of the time an api service as well.
class ListInteractor: ListInteractorDelegate {
    private let favorites: BehaviorRelay<[Section]> = BehaviorRelay(value: [])
    private let disposeBag = DisposeBag()
    private var ratingID: String?
    private var timer: Timer?
    
    // MARK: - ListInteractorDelegate
    func fetchData() {
        let path = Bundle.main.path(forResource: "Favorite", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        
        do {
            let data = try Data(contentsOf: url)
            let result = try JSONDecoder().decode(Favorite.self, from: data)
            let sortedFavorites = result.toViewModel().sorted {$0.rating > $1.rating}
            self.favorites.accept([Section(model: "", items: sortedFavorites)])
        } catch let error {
            print("Fetch json data error: \(error)")
        }
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
        self.ratingID = selectedItem.identity
        return selectedItem.rating
    }
    func userDidFinishRating(newRating: Int) {
        guard let index = section.items.firstIndex(where: {$0.identity == ratingID}) else {return}
        var items = section.items
        items[index].rating = newRating
        items.sort{ $0.rating > $1.rating }
        favorites.accept([Section(model: "", items: items)])
        self.ratingID = nil
    }
}

private extension ListInteractor {
    var section: Section {
        // We only have 1 section
        return favorites.value[0]
    }
    @objc func randomRating() {
        let randIndex = Int.random(in: 0..<section.items.count)
        var items = section.items
        items[randIndex].rating = Int.random(in: 1...5)
        items.sort{ $0.rating > $1.rating }
        favorites.accept([Section(model: "", items: items)])
        
        // Set timer to keep it going
        setTimer()
    }
}
