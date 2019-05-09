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

class ListViewController: UITableViewController {
    // MARK: - Properties
    let disposeBag = DisposeBag()
    let ratingViewTag = 200
    var ratingID: String?
    let favorites: BehaviorRelay<[Section]> = BehaviorRelay(value: [])
    var countingTimer: Timer?
    
    // MARK: - IBOutlets
    @IBOutlet var ratingView: UIView!
    @IBOutlet var cosmosView: CosmosView!
    
    // MARK: - IBActions
    @IBAction func submitPressed(_ sender: Any) {
        dismissRatingView()
    }
    @IBAction func randomRatingPressed(_ sender: UIBarButtonItem) {
        let offText = "RANDOM RATING"
        if sender.title == "RANDOM RATING" {
            sender.title = "RANDOMING..."
            sender.tintColor = .red
            setTimer()
        } else {
            sender.title = offText
            sender.tintColor = nil
            countingTimer?.invalidate()
        }
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
extension ListViewController: ListCellOutput {
    func rateDidPress(cell: ListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        let selectedItem = section.items[indexPath.row]
        self.ratingID = selectedItem.identity
        showRatingView(rating: selectedItem.rating)
    }
}

// MARK: - Private Helpers
private extension ListViewController {
    var section: Section {
        // We only have 1 section
        return favorites.value[0]
    }
    func config() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 55
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
        guard let index = section.items.firstIndex(where: {$0.identity == ratingID}) else {return}
        let rating = Int(cosmosView.rating)
        var items = section.items
        items[index].rating = rating
        items.sort{ $0.rating > $1.rating }
        favorites.accept([Section(model: "", items: items)])
        ratingView.removeFromSuperview()
        self.ratingID = nil
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
    func setTimer() {
        // Create and configure the timer for random intervals
        let randInterval = Double.random(in: 1...10)
        countingTimer = Timer.scheduledTimer(timeInterval: randInterval, target: self, selector: #selector(randomRating), userInfo: nil, repeats: false)
        // Optimize the timer for increased power savings and responsiveness
        countingTimer?.tolerance = randInterval / 2
        // Helps UI stay responsive even with timer.
        RunLoop.current.add(countingTimer!, forMode: RunLoop.Mode.common)
    }
}
