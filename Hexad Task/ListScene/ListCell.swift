//
//  ListCell.swift
//  Hexad Task
//
//  Created by Chieh Teng Wang on 07.05.19.
//  Copyright © 2019 Chieh Teng Wang. All rights reserved.
//

import UIKit

protocol ListCellOutput: class {
    func rateDidPress(cell: ListCell)
}
class ListCell: UITableViewCell {
    // MARK: - Properties
    weak private var output: ListCellOutput?
    
    // MARK: - IBOutlets
    @IBOutlet weak private var title: UILabel!
    @IBOutlet weak private var ratings: UIStackView!
    
    // MARK: - IBActions
    @IBAction func ratePressed(_ sender: UIButton) {
        output?.rateDidPress(cell: self)
    }
    
    // MARK: - Boundary Methods
    func config(item: FavoriteViewModel, output: ListCellOutput) {
        self.output = output
        title.text = item.title
        for (index, img) in ratings.arrangedSubviews.enumerated() {
            img.isHidden = (index + 1) > item.rating
        }
    }
}
