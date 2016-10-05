//
//  MenuViewController.swift
//  Toggelr
//
//  Created by Michel Georgy on 08/09/16.
//  Copyright © 2016 4eyes GmbH. All rights reserved.
//

import UIKit

class MenuViewController : UIViewController {
    @IBOutlet weak var versionInfoLabel: UILabel!
    
    override func viewDidLoad() {
        setVersionInfo();
    }
    
    func setVersionInfo(){
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                self.versionInfoLabel.text = "Version " + version + " (b" + build + ")";
            }
        }
    }
}
