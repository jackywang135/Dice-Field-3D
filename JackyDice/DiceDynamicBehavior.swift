//
//  DiceDynamicBehavior.swift
//  JackyDice
//
//  Created by Jacky Wang on 11/21/14.
//  Copyright (c) 2014 JACKYWANG. All rights reserved.
//

import Foundation
import UIKit

protocol DiceDynamicBehaviorDelegate {
    func contactMade(dice:DiceView)
}

class DiceDynamicBehavior : UIDynamicBehavior, UICollisionBehaviorDelegate {
    
    var collisionBehavior = UICollisionBehavior()
    var dynamicItemBehavior = UIDynamicItemBehavior()
    var gravityBehavior = UIGravityBehavior()
    
    var diceDynamicBehaviorBehavior : DiceDynamicBehaviorDelegate!

    override init() {
        super.init()
        setUpCollisionBehavior()
        setUpDynamicItemBehavior()
        setUpGravityBehavior()
        addChildBehavior(collisionBehavior)
        addChildBehavior(dynamicItemBehavior)
        addChildBehavior(gravityBehavior)
    }
    
    private func setUpCollisionBehavior() {
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.collisionDelegate = self
    }
    
    private func setUpDynamicItemBehavior() {
        dynamicItemBehavior.elasticity = 0.45
        dynamicItemBehavior.resistance = 1
        dynamicItemBehavior.angularResistance = 1
    }
    
    private func setUpGravityBehavior() {
        gravityBehavior.magnitude = 9
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
    
    let finishAnimationAfterTime = Double(5)
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        if let dice = item1 as? DiceView {
            delayClosureWithTime(finishAnimationAfterTime){
                dice.stopAnimating()
            }
        }
		if let dice = item2 as? DiceView {
            delayClosureWithTime(finishAnimationAfterTime) {
				dice.stopAnimating()
			}
		}
    }

    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
        gravityBehavior.removeItem(item)
		if let dice = item as? DiceView {
			delayClosureWithTime(finishAnimationAfterTime) {
				dice.stopAnimating()
			}
		}
    }
}

