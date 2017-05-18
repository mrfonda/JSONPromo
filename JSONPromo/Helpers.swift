//
//  Helpers.swift
//  JSONPromo
//
//  Created by Vladislav Dorfman on 18/05/2017.
//  Copyright © 2017 Vladislav Dorfman. All rights reserved.
//

import Foundation
import UIKit

extension UIView  {
    
    static open func performBubbleEffect(_ cell: UIView)
    {
        self.animate(withDuration: 0.5, animations:
            {
                cell.layer.transform = CATransform3DMakeScale(1.05, 1.05, 1)
        },completion: { _ in
            UIView.animate(withDuration: 0.2, animations:
                {
                    cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
            })
        })
    }
}

//MARK: - CALayer extension

extension CALayer {
    
    func highlight() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        
        animation.fromValue = (1,1)
        animation.toValue = (1.1, 1.1)
        animation.duration = 0.3
        self.add(animation, forKey: "highlight")
        self.animation(forKey: "highlight")
    }
    
    func unhighlight() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = (1.1, 1.1)
        animation.toValue = (1, 1)
        animation.duration = 0.3
        self.add(animation, forKey: "highlight")
        self.animation(forKey: "highlight")
    }
    
    
    
    func newsAnimation() {
        let scaleAnim      = CAKeyframeAnimation(keyPath:"transform")
        scaleAnim.values   = [NSValue(caTransform3D: CATransform3DMakeScale(0, 0, 0)),
                              NSValue(caTransform3D: CATransform3DIdentity)]
        scaleAnim.keyTimes = [0, 1]
        scaleAnim.duration = 2
        
        
        let opacityAnim      = CAKeyframeAnimation(keyPath:"opacity")
        opacityAnim.values   = [0, 1]
        opacityAnim.keyTimes = [0, 1]
        opacityAnim.duration = 2
        
        let rotateAnim      = CAKeyframeAnimation(keyPath:"transform.rotation.z")
        rotateAnim.values   = [0,
                               -2880 * CGFloat(M_PI/180)]
        rotateAnim.keyTimes = [0, 1]
        rotateAnim.duration = 2
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [scaleAnim, rotateAnim, opacityAnim]
        groupAnimation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)
        
        if let animations = groupAnimation.animations {
            for anim in animations {
                anim.fillMode = kCAFillModeForwards
            }
        }
        groupAnimation.fillMode = kCAFillModeForwards
        groupAnimation.isRemovedOnCompletion = false
        
        
        groupAnimation.duration = 2
        
        
        self.add(groupAnimation, forKey: "groupAnimation")
        self.animation(forKey: "groupAnimation")
    }
    func goAway() {
        let scaleAnim      = CAKeyframeAnimation(keyPath:"transform")
        scaleAnim.values   = [NSValue(caTransform3D: CATransform3DMakeScale(0, 0, 0)),
                              NSValue(caTransform3D: CATransform3DIdentity)]
        scaleAnim.keyTimes = [1, 0]
        scaleAnim.duration = 2
        
        
        let opacityAnim      = CAKeyframeAnimation(keyPath:"opacity")
        opacityAnim.values   = [1, 0]
        opacityAnim.keyTimes = [1, 0]
        opacityAnim.duration = 2
        
        let rotateAnim      = CAKeyframeAnimation(keyPath:"transform.rotation.z")
        rotateAnim.values   = [0,
                               -2880 * CGFloat(M_PI/180)]
        rotateAnim.keyTimes = [1, 0]
        rotateAnim.duration = 2
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [scaleAnim, rotateAnim, opacityAnim]
        groupAnimation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseIn)
        
        if let animations = groupAnimation.animations {
            for anim in animations {
                anim.fillMode = kCAFillModeForwards
            }
        }
        groupAnimation.fillMode = kCAFillModeForwards
        groupAnimation.isRemovedOnCompletion = false
        
        
        groupAnimation.duration = 2
        
        
        self.add(groupAnimation, forKey: "groupAnimation")
        self.animation(forKey: "groupAnimation")
    }
}

extension UIColor {
    static func getRandomColor() -> UIColor{
        
        let randomRed:CGFloat = CGFloat(drand48())
        
        let randomGreen:CGFloat = CGFloat(drand48())
        
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
    }
}
//MARK: - enum extension

protocol CaseCountable: RawRepresentable {}
extension CaseCountable where RawValue == Int {
    static var count: RawValue {
        var i: RawValue = 0
        while let _ = Self(rawValue: i) { i += 1 }
        return i
    }
}
