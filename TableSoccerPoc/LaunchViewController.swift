//
//  LaunchViewController.swift
//  Toggelr
//
//  Created by Michel Georgy on 06/09/16.
//  Copyright © 2016 4eyes GmbH. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    @IBOutlet weak var animatedSplashScreen: UIImageView!
    
    var started = false;
    var timer : NSTimer?;
    
    override func viewDidAppear(animated: Bool) {

        super.viewDidAppear(animated);
        
        var animationImages : [UIImage] = [];
        
        for i in 0..<32 {
            animationImages.append(UIImage(named: "anim" + String(i))!);
        }
        
        animatedSplashScreen.animationImages = animationImages;
        animatedSplashScreen.animationRepeatCount=1;
        animatedSplashScreen.animationDuration=1.6;
        
        animatedSplashScreen.startAnimating();
        animatedSplashScreen.image = UIImage(named: "anim32");
        
        started = true;
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(LaunchViewController.didFinishAnimatingImageView), userInfo: nil, repeats: true);
    }
    
    func didFinishAnimatingImageView(){
        if(!animatedSplashScreen.isAnimating() && started){
            timer?.invalidate();
            self.performSegueWithIdentifier("playerselection", sender: self);
        }
    }
}