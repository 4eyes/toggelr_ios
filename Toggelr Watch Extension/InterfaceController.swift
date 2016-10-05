//
//  InterfaceController.swift
//  Toggelr Watch Extension
//
//  Created by Michel Georgy on 04.10.16.
//  Copyright © 2016 4eyes GmbH. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet var redDefence: WKInterfaceButton!
    @IBOutlet var redAttack: WKInterfaceButton!
    @IBOutlet var redDefenceGroup: WKInterfaceGroup!
    @IBOutlet var redAttackGroup: WKInterfaceGroup!
    
    @IBOutlet var blueDefence: WKInterfaceButton!
    @IBOutlet var blueAttack: WKInterfaceButton!
    @IBOutlet var blueDefenceGroup: WKInterfaceGroup!
    @IBOutlet var blueAttackGroup: WKInterfaceGroup!
    
    var buttonRadius : CGFloat = 27.5
    ;
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        redDefenceGroup.setCornerRadius(buttonRadius);
        redAttackGroup.setCornerRadius(buttonRadius);
        blueDefenceGroup.setCornerRadius(buttonRadius);
        blueAttackGroup.setCornerRadius(buttonRadius);
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
