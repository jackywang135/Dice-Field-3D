//
//  DiceDynamicBehavior.swift
//  JackyDice
//
//  Created by Jacky Wang on 11/21/14.
//  Copyright (c) 2014 JACKYWANG. All rights reserved.
//

import Foundation
import UIKit

class DiceDynamicBehavior : UIDynamicBehavior, UICollisionBehaviorDelegate {
    
    var collisionBehavior = UICollisionBehavior()
    var dynamicItemBehavior = UIDynamicItemBehavior()
    var gravityBehavior = UIGravityBehavior()
    
    override init() {
        super.init()
        setUpCollisionBehavior()
        setUpDynamicItemBehavior()
        addChildBehavior(collisionBehavior)
        addChildBehavior(dynamicItemBehavior)
        addChildBehavior(gravityBehavior)
    }
    
    func setUpCollisionBehavior() {
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.collisionDelegate = self
    }
    
    func setUpDynamicItemBehavior() {
        dynamicItemBehavior.elasticity = 0.5
        dynamicItemBehavior.resistance = 1
        dynamicItemBehavior.angularResistance = 1
    }
    
    func addItem(item : UIDynamicItem) {
        collisionBehavior.addItem(item)
        gravityBehavior.addItem(item)
        dynamicItemBehavior.addItem(item)
    }
    
    func removeItem(item : UIDynamicItem) {
        collisionBehavior.removeItem(item)
        gravityBehavior.removeItem(item)
        dynamicItemBehavior.removeItem(item)
    }
    
    let finishAnimationAfterTime = Double(0.75)
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        gravityBehavior.removeItem(item1)
        gravityBehavior.removeItem(item2)
        if item1 is DiceView {
            (item1 as DiceView).animateRollingSlowly()
            delayClosureWithTime(finishAnimationAfterTime){ (item1 as DiceView).stopAnimating()}
        }
        if item2 is DiceView {
            (item2 as DiceView).animateRollingSlowly()
            delayClosureWithTime(finishAnimationAfterTime){ (item2 as DiceView).stopAnimating()}
        }
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
        gravityBehavior.removeItem(item)
        if item is DiceView {
            (item as DiceView).animateRollingSlowly()
            delayClosureWithTime(finishAnimationAfterTime){ (item as DiceView).stopAnimating()}
        }
    }
}