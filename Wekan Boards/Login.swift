//
//  Login.swift
//  Wekan Boards
//
//  Created by Guillaume on 29/01/2018.
//

import Cocoa

class Login: NSViewController {
    
    var bearer = ""

    @IBOutlet weak var rootURL: NSTextField!
    @IBOutlet weak var login: NSTextField!
    @IBOutlet weak var password: NSTextField!
    @IBAction func getToken(_ sender: NSButton) {
        let params = ["username": login.stringValue, "password": password.stringValue]
        var request = URLRequest(url: URL(string: "\(rootURL.stringValue)/users/login")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if data != nil {
                do {
                    let credentials = try JSONSerialization.jsonObject(with: data!) as! NSDictionary
                    self.bearer = "\(credentials["token"]!)"
                    self.goStatus.isEnabled = true
                    sender.isEnabled = false
                } catch {
                    print("error")
                }
                
            }
        })
        task.resume()
    }
    
    @IBOutlet weak var goStatus: NSButton!
    @IBAction func Go(_ sender: Any) {
        performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "loginOK"), sender: self)
        self.dismiss(sender)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        rootURL.becomeFirstResponder()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier!.rawValue == "loginOK" {
            let controller: ViewController = segue.destinationController as! ViewController
            controller.bearer = self.bearer
            controller.rootURL = self.rootURL.stringValue
        }
    }
    
}
