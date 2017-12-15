//
//  ViewController.swift
//  js2iOS
//
//  Created by MJ on 2017. 12. 14..
//  Copyright © 2017년 mj.example. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    let methods = ["showToast", "showLog", "getMessage"]
    
    override func loadView() {
        super.loadView()

        webView.configuration.userContentController = makeUserContentController(methods: methods)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard
            let path = Bundle.main.path(forResource: "web", ofType: "html")
        else {
            print("cannot load file")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        let req = URLRequest(url: url)
        
        webView.load(req)
    }
    
    @IBAction func onTouchUpBtn(_ sender: Any) {
        callJsGetInteger() {
            self.showAlertViewController("value from JS : [\($0 ?? (-1))]")
        }
    }
}

extension ViewController {
    func showAlertViewController(_ message : String, buttonMessage : String = "Dismiss",
                                 handler: ((UIAlertAction) -> Void)? = nil){
        let alertController = UIAlertController(title : "js2iOS", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: buttonMessage, style: UIAlertActionStyle.default, handler: handler))
        
        present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: WKScriptMessageHandler {
    func makeUserContentController(methods: [String]) -> WKUserContentController {
        let contentController = WKUserContentController();
        
        methods.forEach {
            contentController.add(
                self,
                name: $0
            )
        }
        
        return contentController
    }
    
    func callJsGetMessageCallback(message: String) {
        webView.evaluateJavaScript("window.getMessageCallback && window.getMessageCallback('\(message)')")
    }
    
    func callJsGetInteger(callback: @escaping (Int?) -> ()) {
        webView.evaluateJavaScript("window.getInteger && window.getInteger()") { (result, error) in
            if let integer = result as? Int {
                callback(integer)
            } else {
                callback(nil)
            }
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        switch message.name {
        case "showLog":
            if
                let sentData = message.body as? NSDictionary,
                let message = sentData["message"] as? String,
                let value = sentData["value"] as? Int
            {
                print("FromJS: string message : [\(message)], int value [\(value)]")
            }
        case "showToast":
            if
                let sentData = message.body as? NSDictionary,
                let message = sentData["message"] as? String,
                let lengthLong = sentData["lengthLong"] as? Bool
            {
                showAlertViewController(message, buttonMessage: "lengthLong: [\(lengthLong)]", handler: nil)
            }
        case "getMessage":
            callJsGetMessageCallback(message: "message: [\(Int(arc4random_uniform(100) + 1))]")
        default:
            print("default")
        }
    }
}

