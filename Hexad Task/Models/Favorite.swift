//
//  Favorite.swift
//  Hexad Task
//
//  Created by Chieh Teng Wang on 09.05.19.
//  Copyright © 2019 Chieh Teng Wang. All rights reserved.
//

import Foundation
import RxDataSources

struct Favorite: IdentifiableType, Equatable {
    let identity: String
    var title: String
    var rating: Int
}
