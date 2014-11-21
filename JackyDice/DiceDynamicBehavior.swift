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
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        gravityBehavior.removeItem(item1)
        gravityBehavior.removeItem(item2)
    }
}