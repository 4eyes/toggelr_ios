//
//  PlayerView.swift
//  TableSoccerPoc
//
//  Created by Michel Georgy on 10/09/15.
//  Copyright (c) 2015 4eyes GmbH. All rights reserved.
//

import UIKit

class PlayerView: UIView {
    var lastLocation:CGPoint = CGPointMake(0, 0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
        let panRecognizer = UIPanGestureRecognizer(target:self, action:"detectPan:")
        self.gestureRecognizers = [panRecognizer]
        
        //randomize view color
        let blueValue = CGFloat(Int(arc4random() % 255)) / 255.0
        let greenValue = CGFloat(Int(arc4random() % 255)) / 255.0
        let redValue = CGFloat(Int(arc4random() % 255)) / 255.0
        
        self.backgroundColor = UIColor(red:redValue, green: greenValue, blue: blueValue, alpha: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func detectPan(recognizer:UIPanGestureRecognizer) {
        let translation  = recognizer.translationInView(self.superview!)
        self.center = CGPointMake(lastLocation.x + translation.x, lastLocation.y + translation.y)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Promote the touched view
        self.superview?.bringSubviewToFront(self)
        
        // Remember original location
        lastLocation = self.center
    }
}
