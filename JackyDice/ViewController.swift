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

let diceWidth = CGFloat(80)

func delayClosureWithTime(delay : Double, closure: () -> ()) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
}

class ViewController: UIViewController, DiceViewDelegate {
    
    var animator : UIDynamicAnimator!
    var diceBehavior = DiceDynamicBehavior()
    
    //let diceWidth = CGFloat(90)
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
        setUpUIDynamics()
        addNewDice()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    func setUpUIDynamics() {
        animator = UIDynamicAnimator(referenceView: self.view)
        diceBehavior.collisionBehavior.addBoundaryWithIdentifier("shakeButtonBorder", fromPoint: buttonShake.frame.origin, toPoint: CGPointMake(screenWidth, screenHeight - buttonShakeHeight))
        animator.addBehavior(diceBehavior)
    
    }
    
    func setUpUI() {
        setUpBackground()
        setUpShakeButton()
    }
    
    func setUpBackground() {
        var casinoGreenColor = UIColor(hue: 135/360, saturation: 73/100, brightness: 44/100, alpha: 1)
        view.backgroundColor! = casinoGreenColor
        var backgroundImageView = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImageView.image = UIImage(named: "pokerTableFelt")
        backgroundImageView.contentMode = .ScaleAspectFill
        view.addSubview(backgroundImageView)
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
        view.addSubview(diceView)
        diceBehavior.addItem(diceView)
        diceView.delegate = self
    }
    
    func delaySecondsCallClosure(delay: Double, closure:() -> ()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
    }
    
    func tapOnDiceView(diceView: DiceView) {
        if diceViewInView.count == 1 {
            return
        }
        diceBehavior.removeItem(diceView)
        diceView.removeFromSuperview()
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent) {
        if motion == UIEventSubtype.MotionShake {
            rollAllDice()
        }
    }
    
    func animateDicePush() {
        for diceView in diceViewInView {
            var dicePushBehavior = UIPushBehavior(items:[diceView], mode: UIPushBehaviorMode.Instantaneous)
            dicePushBehavior.magnitude = 7
            let degreeToRadianConverter = CGFloat(M_PI) / CGFloat(180)
            let randomDegree = arc4random_uniform(UInt32(360))
            let radians = CGFloat(randomDegree) * degreeToRadianConverter
            dicePushBehavior.angle = radians
            dicePushBehavior.active = true
            dicePushBehavior.addItem(diceView)
            let offset = UIOffsetMake(-diceWidth/4, diceWidth/4)
            dicePushBehavior.setTargetOffsetFromCenter(offset, forItem: diceView)
            animator.addBehavior(dicePushBehavior)
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
        //addNewDice()
    }
    
}