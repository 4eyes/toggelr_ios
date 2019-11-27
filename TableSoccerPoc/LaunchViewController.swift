//
//  LaunchViewController.swift
//  Toggelr
//
//  Created by Michel Georgy on 06/09/16.
//  Copyright © 2016 4eyes GmbH. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController, CAAnimationDelegate{
    @IBOutlet weak var animatedSplashScreen: UIImageView!
    
    var started = false;
    var timer : Timer?;
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);

        startAnimation();
    }
    
    func startAnimation(){
        let animationImageCount = 32;
        var animationImages : [CGImage] = [];
        
        for i in 0..<animationImageCount {
            animationImages.append(UIImage(named: "anim" + String(i))!.cgImage!);
        }
        
        let animation = CAKeyframeAnimation(keyPath: "contents");
        animation.calculationMode = CAAnimationCalculationMode.discrete;
        animation.duration = Double(animationImageCount) / 20.0; // 20 frames per second
        animation.values = animationImages;
        animation.repeatCount = 1;
        animation.isRemovedOnCompletion = false;
        animation.fillMode = CAMediaTimingFillMode.forwards;
        animation.delegate = self;
        self.animatedSplashScreen.layer.add(animation, forKey: "animation");
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.performSegue(withIdentifier: "playerselection", sender: self);
    }
}
