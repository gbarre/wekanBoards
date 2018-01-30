//
//  Board.swift
//  Wekan Boards
//
//  Created by Guillaume on 29/01/2018.
//

import Cocoa

class Board: NSObject {

    var id: String
    var name: String
    var usersId = [String]()
    
    required init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
