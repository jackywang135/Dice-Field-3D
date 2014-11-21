//
//  ViewController.swift
//  JackyDice
//
//  Created by JackyWang on 11/19/14.
//  Copyright (c) 2014 JackyWang. All rights reserved.
//

import UIKit

let screenWidth = UIScreen.mainScreen().bounds.width
let screenHeight = UIScreen.mainScreen().bounds.height

class ViewController: UIViewController, DiceViewDelegate {
    
    var animator : UIDynamicAnimator!
    var diceBehavior : UIDynamicBehavior!
    var collisionBehavior : UICollisionBehavior!
    var pushBehavior : UIPushBehavior!
    var gravityBehavior : UIGravityBehavior!
    var dynamicItemBehavior : UIDynamicItemBehavior!
    
    let diceWidth = CGFloat(100)
    var buttonShake : UIButton!

    var diceViewInView : [DiceView] {
        get {
            var array = [DiceView]()
            for view in self.view.subviews {
                if view is DiceView {
                    array.append(view as DiceView)
                }
            }
            return array
        }
    }
    
    var total : Int {
        get {
            var sum = 0
            for diceView in diceViewInView {
                sum = sum + diceView.number
            }
            return sum
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpUIDynamicKit()
        addNewDice()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setUpUI() {
        setUpBackground()
        setUpShakeButton()
    }
    
    func setUpBackground() {
        var casinoGreenColor = UIColor(hue: 135/360, saturation: 73/100, brightness: 44/100, alpha: 1)
        view.backgroundColor! = casinoGreenColor
    }
    
    let buttonShakeHeight = screenHeight/10
    let buttonShakeWidth = screenWidth
    
    func setUpShakeButton() {
        buttonShake = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        buttonShake.frame = CGRectMake(0, screenHeight - buttonShakeHeight, buttonShakeWidth, buttonShakeHeight)
        buttonShake.setTitle("Shake", forState: UIControlState.Normal)
        buttonShake.setBackgroundImage(UIImage(named: "wood"), forState: UIControlState.Normal)
        buttonShake.addTarget(self, action: "buttonShake:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(buttonShake)
        
    }
    
    func addNewDice() {
        let screenWidth = UIScreen.mainScreen().bounds.width
        let diceViewXposition = Int(arc4random_uniform(UInt32(screenWidth - diceWidth)))
        var diceView = DiceView(frame: CGRectMake(CGFloat(diceViewXposition), 0, diceWidth, diceWidth))
        if diceViewInView.count == 0 {
            diceView.removeGestureRecognizer(diceView.tapGesture!)
        }
        view.addSubview(diceView)
        collisionBehavior.addItem(diceView)
        gravityBehavior.addItem(diceView)
        dynamicItemBehavior.addItem(diceView)
        delaySecondsCallClosure(3){ self.gravityBehavior.removeItem(diceView) }
        diceView.delegate = self
    }
    
    func delaySecondsCallClosure(delay: Double, closure:() -> ()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
    }
    
    func tapOnDiceView(diceView: DiceView) {
        collisionBehavior.removeItem(diceView)
        gravityBehavior.removeItem(diceView)
        dynamicItemBehavior.removeItem(diceView)
        diceView.removeFromSuperview()
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent) {
        if motion == UIEventSubtype.MotionShake {
            rollAllDice()
        }
    }
    
    func setUpUIDynamicKit() {
        animator = UIDynamicAnimator(referenceView: self.view)
        
        diceBehavior = UIDynamicBehavior()
        
        collisionBehavior = UICollisionBehavior()
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.addBoundaryWithIdentifier("shakeButtonBorder", fromPoint: buttonShake.frame.origin, toPoint: CGPointMake(screenWidth, screenHeight - buttonShakeHeight))
        
        gravityBehavior = UIGravityBehavior()
        
        dynamicItemBehavior = UIDynamicItemBehavior()
        dynamicItemBehavior.elasticity = 0.5
        dynamicItemBehavior.resistance = 1
        dynamicItemBehavior.angularResistance = 1
        
        diceBehavior.addChildBehavior(collisionBehavior)
        diceBehavior.addChildBehavior(gravityBehavior)
        diceBehavior.addChildBehavior(dynamicItemBehavior)
        
        animator.addBehavior(diceBehavior)
        
    }
    
    func animateDicePush() {
        for diceView in diceViewInView {
            var dicePushBehavior = UIPushBehavior(items:[diceView], mode: UIPushBehaviorMode.Instantaneous)
            dicePushBehavior.magnitude = 5
            let degreeToRadianConverter = CGFloat(M_PI) / CGFloat(180)
            let randomDegree = arc4random_uniform(UInt32(360))
            let radians = CGFloat(randomDegree) * degreeToRadianConverter
            dicePushBehavior.angle = radians
            dicePushBehavior.active = true
            dicePushBehavior.addItem(diceView)
            let offset = UIOffsetMake(-diceWidth/4, diceWidth/4)
            dicePushBehavior.setTargetOffsetFromCenter(offset, forItem: diceView)
            animator.addBehavior(dicePushBehavior)
            //delaySecondsCallClosure(0.5){ dicePushBehavior.active = false}
            //diceBehavior.addChildBehavior(dicePushBehavior)
        }
    }
    
    func rollAllDice() {
        animateDicePush()
        for diceView in diceViewInView {
            diceView.roll()
        }
    }
    
    func buttonAddPressed(sender: UIButton) {
        addNewDice()
    }

    func buttonShake(sender: UIButton) {
        rollAllDice()
    }
}