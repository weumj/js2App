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
    var webView: WKWebView!
    let methods = ["showToast", "showLog", "getMessage"]
    
    override func loadView() {
        super.loadView()
        
        webView = WKWebView(frame: .zero, configuration: getWebViewConfig(methods: methods))
        view = webView
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
    func getWebViewConfig(methods: [String]) -> WKWebViewConfiguration {
        let contentController = WKUserContentController();
        
        methods.forEach {
            contentController.add(
                self,
                name: $0
            )
        }
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        return config
    }
    
    func callJsGetMessageCallback(message: String) {
        webView.evaluateJavaScript("window.getMessageCallback && window.getMessageCallback('\(message)')")
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

