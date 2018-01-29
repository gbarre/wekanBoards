//
//  ViewController.swift
//  Wekan Boards
//
//  Created by Guillaume on 29/01/2018.
//  Copyright © 2018 Guillaume. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    var bearer = ""
    var rootURL: String = ""
    var mode = "users"
    
    var usersArray = [User]()
    var usersNames = [String]()
    var usersInBoardsArray = [String: [String]]()
    var boardsArray = [Board]()
    var boardsId = [String]()
    var boardsNames = [String]()
    
    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var leftColumn: NSTableColumn!
    @IBOutlet weak var rightColumn: NSTableColumn!
    
    @IBAction func showUsers(_ sender: Any) {
        mode = "users"
        leftColumn.title = "User"
        rightColumn.title = "Boards"
        for userObject in usersArray {
            for board in userObject.boards {
                let boardTitle = board.name
                let boardId = board.id
                if (!boardsId.contains(boardId)) {
                    boardsArray.append(board)
                    boardsId.append(boardId)
                    boardsNames.append(boardTitle)
                }
            }
        }
        usersArray = usersArray.sorted(by: {$0.name.compare($1.name, options: .caseInsensitive) == .orderedAscending})
        boardsArray = boardsArray.sorted(by: {$0.name.compare($1.name, options: .caseInsensitive) == .orderedAscending})
        outlineView.reloadData()
    }
    
    @IBAction func showBoards(_ sender: Any) {
        mode = "boards"
        leftColumn.title = "Boards"
        rightColumn.title = "Users"
        for userObject in usersArray {
            let userName = userObject.name
            for board in userObject.boards {
                let boardTitle = board.name
                let boardId = board.id
                if usersInBoardsArray[boardTitle] == nil {
                    var user = [String]()
                    user.append(userName)
                    usersInBoardsArray[boardTitle] = user
                } else if !(usersInBoardsArray[boardTitle]?.contains(userName))! {
                    usersInBoardsArray[boardTitle]?.append(userName)
                }
                if (!boardsId.contains(boardId)) {
                    boardsArray.append(board)
                    boardsId.append(boardId)
                    boardsNames.append(boardTitle)
                }
            }
        }
        usersArray = usersArray.sorted(by: {$0.name.compare($1.name, options: .caseInsensitive) == .orderedAscending})
        boardsArray = boardsArray.sorted(by: {$0.name.compare($1.name, options: .caseInsensitive) == .orderedAscending})
        outlineView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        outlineView.dataSource = self
        outlineView.delegate = self
        
        var request = URLRequest(url: URL(string: "\(rootURL)/api/users")!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                let users = try JSONSerialization.jsonObject(with: data!) as! [NSDictionary]
                var i = 0
                for user in users {
                    let userId = "\(user["_id"]!)"
                    let userName = "\(user["username"]!)"
                    self.usersNames.append(userName)
                    self.usersArray.insert(User(id: userId, name: userName), at: i)
                    self.usersArray[i].getBoards(rootURL: self.rootURL, bearer: self.bearer)
                    i = i + 1
                }
            } catch {
                print("error")
            }
        })
        task.resume()
    }
    
    // Give a unique identifier for each row
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return (mode == "users") ? usersArray[index].name : boardsArray[index].id
        } else if mode == "users" && usersNames.contains(item as! String) {
            let userIndex = usersNames.index(of: item as! String)
            return usersArray[userIndex!].boards[index].id
        } else if mode == "boards" && boardsId.contains(item as! String) {
            let boardIndex = getBoardName(id: item as! String)
            return usersInBoardsArray[boardIndex]![index]
        } else {
            return "none"
        }
    }
    
    // Tell how many children each row has:
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return (mode == "users") ? usersArray.count : boardsId.count
        } else if mode == "users" &&  usersNames.contains(item as! String) {
            let index = usersNames.index(of: item as! String)
            return usersArray[index!].boards.count
        } else if mode == "boards" && boardsId.contains(item as! String) {
            let index = getBoardName(id: item as! String)
            return usersInBoardsArray[index]!.count
        } else {
            return 0
        }
    }
    
    // Tell whether the row is expandable.
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if mode == "users" {
            if let item = item as? String, usersNames.contains(item) {
                return true
            } else {
                return false
            }
        } else {
            if  let item = item as? String, boardsId.contains(item) {
                return true
            } else {
                return false
            }
        }
    }
    
    // Set the text for each row
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let columnIdentifier = tableColumn?.identifier else {
            return nil
        }
        
        var text = ""
        let itemString = "\(item)"
        switch (columnIdentifier.rawValue, itemString, mode) {
        case ("keyColumn", itemString, "users"):
            if usersNames.contains(itemString) {
                text = itemString
            }
        case ("keyColumn", itemString, "boards"):
            if boardsId.contains(itemString) {
                text = getBoardName(id: itemString)
            }
        case ("valueColumn", itemString, "users"):
            if boardsId.contains(itemString) {
                let index = boardsId.index(of: itemString)
                text = boardsNames[index!]
            }
        case ("valueColumn", itemString, "boards"):
            if usersNames.contains(itemString) {
                text = itemString
            }
        default:
            break
        }
        
        let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "outlineViewCell"), owner: self) as! NSTableCellView
        cell.textField!.stringValue = text
        
        return cell
    }
    
    func getBoardName(id: String) -> String {
        var index = ""
        for board in boardsArray {
            if board.id == id {
                index = board.name
            }
        }
        return index
    }
    
        
}

