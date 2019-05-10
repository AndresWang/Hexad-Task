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

// The viewcontroller here just control and talk with its subviews, and it sends all the requests only to its interactor if it needs anything.
class ListViewController: UITableViewController {
    // MARK: - Init Properties
    private var interactor: ListInteractorDelegate!
    
    // MARK: - Private Properties
    private var isRandoming = false
    
    // MARK: - IBOutlets
    @IBOutlet private var ratingView: UIView!
    @IBOutlet private var cosmosView: CosmosView!
    
    // MARK: - IBActions
    @IBAction func submitPressed(_ sender: Any) {
        interactor.userDidFinishRating(newRating: Int(cosmosView.rating))
        ratingView.removeFromSuperview()
    }
    @IBAction func randomRatingPressed(_ sender: UIBarButtonItem) {
        let offText = NSLocalizedString("RANDOM RATING", comment: "NavBar button")
        let onText = NSLocalizedString("RANDOMING...", comment: "NavBar button")
        if isRandoming {
            sender.title = offText
            sender.tintColor = nil
            interactor.cancelTimer()
            isRandoming = false
        } else {
            sender.title = onText
            sender.tintColor = .red
            interactor.setTimer()
            isRandoming = true
        }
    }
    
    // MARK: - View Events
    override func awakeFromNib() {
        super.awakeFromNib()
        hookUpComponents()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        interactor.fetchData()
        config()
    }
}
// MARK: - ListCellOutput
extension ListViewController: ListCellOutput {
    func rateDidPress(cell: ListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let selectedRating = interactor.userDidSelectAnItemToRate(index: indexPath.row)
        showRatingView(rating: selectedRating)
    }
}
// MARK: - Private Helpers
private extension ListViewController {
    func hookUpComponents() {
        let interactor: ListInteractorDelegate = ListInteractor()
        self.interactor = interactor
    }
    func config() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 55
        ratingView.translatesAutoresizingMaskIntoConstraints = false
        bindTableView()
    }
    func bindTableView() {
        tableView.dataSource = nil
        let dataSource = RxTableViewSectionedAnimatedDataSource<Section>(
            configureCell: { _, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
                cell.config(item: item, output: self)
                return cell
        })
        interactor.bindTableView(dataSource, tableView)
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
}
