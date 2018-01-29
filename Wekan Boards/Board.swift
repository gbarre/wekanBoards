//
//  Board.swift
//  Wekan Boards
//
//  Created by Guillaume on 29/01/2018.
//  Copyright © 2018 Guillaume. All rights reserved.
//

import Cocoa

class Board: NSObject {

    var id: String
    var name: String
    
    required init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
