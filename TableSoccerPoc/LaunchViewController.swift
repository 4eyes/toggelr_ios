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

        startAnimation();
    }
    
    func startAnimation(){
        let animationImageCount = 32;
        var animationImages : [CGImage] = [];
        
        for i in 0..<animationImageCount {
            animationImages.append(UIImage(named: "anim" + String(i))!.CGImage!);
        }
        
        let animation = CAKeyframeAnimation(keyPath: "contents");
        animation.calculationMode = kCAAnimationDiscrete;
        animation.duration = Double(animationImageCount) / 20.0; // 20 frames per second
        animation.values = animationImages;
        animation.repeatCount = 1;
        animation.removedOnCompletion = false;
        animation.fillMode = kCAFillModeForwards;
        animation.delegate = self;
        self.animatedSplashScreen.layer.addAnimation(animation, forKey: "animation");
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        self.performSegueWithIdentifier("playerselection", sender: self);
    }
}