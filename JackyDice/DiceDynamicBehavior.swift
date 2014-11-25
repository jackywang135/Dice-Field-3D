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
        setUpGravityBehavior()
        addChildBehavior(collisionBehavior)
        addChildBehavior(dynamicItemBehavior)
        addChildBehavior(gravityBehavior)
    }
    
    func setUpCollisionBehavior() {
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.collisionDelegate = self
    }
    
    func setUpDynamicItemBehavior() {
        dynamicItemBehavior.elasticity = 0.65
        dynamicItemBehavior.resistance = 1
        dynamicItemBehavior.angularResistance = 1
    }
    
    func setUpGravityBehavior() {
        gravityBehavior.magnitude = 3
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
    
    //MARK: Collision Delegate methods
    
    let finishAnimationAfterTime = Double(1)
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        if item1 is DiceView {
            delayClosureWithTime(finishAnimationAfterTime){ (item1 as DiceView).stopAnimating()}
        }
        if item2 is DiceView {
            delayClosureWithTime(finishAnimationAfterTime){ (item2 as DiceView).stopAnimating()}
        }
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
        gravityBehavior.removeItem(item)
        if item is DiceView {
            delayClosureWithTime(finishAnimationAfterTime){ (item as DiceView).stopAnimating()}
        }
    }
}