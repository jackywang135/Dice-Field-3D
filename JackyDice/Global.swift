//
//  Global.swift
//  JackyDice
//
//  Created by Jacky Wang on 12/3/14.
//  Copyright (c) 2014 JACKYWANG. All rights reserved.
//

import Foundation
import UIKit

//MARK: Global Variables

let diceWidth = CGFloat(60)

let screenWidth = UIScreen.mainScreen().bounds.width
let screenHeight = UIScreen.mainScreen().bounds.height


//MARK: Global Functions

func delayClosureWithTime(delay : Double, closure: () -> ()) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
}

func afterAnimationCompleteDoClosure(animation:()->(), closure:()->()) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(closure)
    animation()
    CATransaction.commit()
}

func animateViewPop(view : UIView) {
    view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001)
    UIView.animateWithDuration(0.2/1.5, animations: {view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1)}, completion: {(complete : Bool) in
        UIView.animateWithDuration(0.2/2, animations: {view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9)}, completion: {(complete : Bool) in
            UIView.animateWithDuration(0.2/2, animations: {view.transform = CGAffineTransformIdentity
            })
        })
    })}
