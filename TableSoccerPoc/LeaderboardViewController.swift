//
//  LeaderboardViewController.swift
//  Toggelr
//
//  Created by Michel Georgy on 08/09/16.
//  Copyright © 2016 4eyes GmbH. All rights reserved.
//

import UIKit
import WebKit
import SWRevealViewController

class LeaderboardViewController : UIViewController{
    @IBOutlet weak var menuButton:UIBarButtonItem!
    
    var webView: WKWebView?
    
    override func loadView() {
        super.loadView()
        webView = WKWebView(frame:self.view.frame)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: true);
        
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        let urlRequest = URLRequest(url: URL(string: "https://toggelr.4eyes.ch")!)
        webView?.load(urlRequest);
        
        self.view.addSubview(webView!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
