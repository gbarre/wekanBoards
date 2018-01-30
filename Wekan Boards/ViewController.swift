//
//  ViewController.swift
//  Wekan Boards
//
//  Created by Guillaume on 29/01/2018.
//

import Cocoa

class ViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    var bearer = ""
    var rootURL: String = ""
    var mode = "users"
    
    var usersDict = [String: User]()
    var boardsDict = [String: Board]()
    
    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var leftColumn: NSTableColumn!
    @IBOutlet weak var rightColumn: NSTableColumn!
    
    @IBAction func showUsers(_ sender: Any) {
        mode = "users"
        leftColumn.title = "User"
        rightColumn.title = "Boards"
        buildBoardsDict()
        outlineView.reloadData()
    }
    
    @IBAction func showBoards(_ sender: Any) {
        mode = "boards"
        leftColumn.title = "Boards"
        rightColumn.title = "Users"
        buildBoardsDict()
        outlineView.reloadData()
        
    }
    
    func buildBoardsDict() {
        if boardsDict.count == 0 {
            for (userId, userObject) in usersDict {
                for board in userObject.boards {
                    let boardId = board.id
                    if !Array(boardsDict.keys).contains(boardId) {
                        board.usersId.append(userId)
                        boardsDict[boardId] = board
                    } else if !(boardsDict[boardId]?.usersId.contains(userId))! {
                        boardsDict[boardId]?.usersId.append(userId)
                    }
                }
            }
        }
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
                    self.usersDict[userId] = User(id: userId, name: userName)
                    self.usersDict[userId]?.getBoards(rootURL: self.rootURL, bearer: self.bearer)
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
            return (mode == "users") ? Array(usersDict.keys)[index] : Array(boardsDict.keys)[index]
        } else if mode == "users" && Array(usersDict.keys).contains(item as! String) {
            return usersDict[item as! String!]!.boards[index].id
        } else if mode == "boards" && Array(boardsDict.keys).contains(item as! String) {
            return boardsDict[item as! String!]!.usersId[index]
        } else {
            return "none"
        }
    }
    
    // Tell how many children each row has:
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return (mode == "users") ? usersDict.count : boardsDict.count
        } else if mode == "users" &&  Array(usersDict.keys).contains(item as! String) {
            return usersDict[item as! String]!.boards.count
        } else if mode == "boards" && Array(boardsDict.keys).contains(item as! String) {
            return boardsDict[item as! String]!.usersId.count
        } else {
            return 0
        }
    }
    
    // Tell whether the row is expandable.
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if mode == "users" {
            if let item = item as? String, Array(usersDict.keys).contains(item) {
                return true
            } else {
                return false
            }
        } else {
            if  let item = item as? String, Array(boardsDict.keys).contains(item) {
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
            if Array(usersDict.keys).contains(itemString) {
                text = (usersDict[itemString]?.name)!
            }
        case ("keyColumn", itemString, "boards"):
            if Array(boardsDict.keys).contains(itemString) {
                text = (boardsDict[itemString]?.name)!
            }
        case ("valueColumn", itemString, "users"):
            if Array(boardsDict.keys).contains(itemString) {
                text = (boardsDict[itemString]?.name)!
            }
        case ("valueColumn", itemString, "boards"):
            if Array(usersDict.keys).contains(itemString) {
                text = (usersDict[itemString]?.name)!
            }
        default:
            break
        }
        
        let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "outlineViewCell"), owner: self) as! NSTableCellView
        cell.textField!.stringValue = text
        
        return cell
    }  
}

