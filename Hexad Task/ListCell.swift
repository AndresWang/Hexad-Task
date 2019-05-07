//
//  ListCell.swift
//  Hexad Task
//
//  Created by Chieh Teng Wang on 07.05.19.
//  Copyright © 2019 Chieh Teng Wang. All rights reserved.
//

import UIKit

class ListCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var ratings: UIStackView!
    
    // MARK: - View Events
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - IBActions
    @IBAction func ratePressed(_ sender: UIButton) {
        
    }
    

}