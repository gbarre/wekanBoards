//
//  User.swift
//  Wekan Boards
//
//  Created by Guillaume on 29/01/2018.
//

import Cocoa

class User: NSObject {
    
    var id: String
    var name: String
    var boards = [Board]()
    
    required init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    func getBoards(rootURL: String, bearer: String) {
        let baseURL = URL(string: "\(rootURL)/api/users/\(id)/boards")!
        
        let session = URLSession.shared
        var request = URLRequest(url: baseURL)
        request.httpMethod = "GET"
        request.addValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                let boards = try JSONSerialization.jsonObject(with: data!) as! [NSDictionary]
                for board in boards {
                    let boardId = "\(board["_id"]!)"
                    let boardTitle = "\(board["title"]!)"
                    self.boards.append(Board(id: boardId, name: boardTitle))
                }
            } catch {
                print("error")
            }
        })
        task.resume()
    }

}
