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

let diceWidth = CGFloat(60)

func delayClosureWithTime(delay : Double, closure: () -> ()) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
}

class ViewController: UIViewController, DiceViewDelegate, BottomViewDelegate {
    
    //MARK: UIDynamicKit
    var animator : UIDynamicAnimator!
    var diceBehavior = DiceDynamicBehavior()
    
    //MARK: UI
    var buttonShake : UIButton!
    var bottomView : BottomView!

    //MARK: Collection & Total
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
    
    //MARK: Set Up
    func setUpUIDynamics() {
        animator = UIDynamicAnimator(referenceView: self.view)
        diceBehavior.collisionBehavior.addBoundaryWithIdentifier("shakeButtonBorder",fromPoint: bottomView.frame.origin, toPoint: CGPointMake(screenWidth, screenHeight - bottomViewHeight))
        animator.addBehavior(diceBehavior)
        

    }
    func setUpUI() {
        setUpBackground()
        setUpBottomView()
        //setUpShakeButton()
    }
    
    let bottomViewHeight = screenHeight/10
    let bottomViewWidth = screenWidth
    
    func setUpBackground() {
        var backgroundImageView = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImageView.image = UIImage(named: "greenFelt")
        backgroundImageView.contentMode = .ScaleAspectFill
        view.addSubview(backgroundImageView)
    }
    
    func setUpBottomView() {
        bottomView = BottomView(frame: CGRectMake(0, screenHeight - bottomViewHeight, bottomViewWidth, bottomViewHeight))
        bottomView.delegate = self
        updateTotalLabel()
        view.addSubview(bottomView)
    }
    
    func updateTotalLabel() {
        bottomView.labelTotal.text = "\(total)"
    }
    
    //MARK: Dice Functions
    func addNewDice() {
        let screenWidth = UIScreen.mainScreen().bounds.width
        let diceViewXposition = Int(arc4random_uniform(UInt32(screenWidth - diceWidth)))
        var diceView = DiceView(frame: CGRectMake(CGFloat(diceViewXposition), 0, diceWidth, diceWidth))
        view.addSubview(diceView)
        diceBehavior.addItem(diceView)
        diceView.delegate = self
        updateTotalLabel()
    }
    
    func rollAllDice() {
        animateDicePush()
        for diceView in diceViewInView {
            diceView.roll()
        }
    }
    
    //MARK: Animation
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
            let randomHorizontalOffset = CGFloat(arc4random_uniform(UInt32(diceWidth/2) - UInt32(diceWidth/4)))
            let randomVerticalOffset = CGFloat(arc4random_uniform(UInt32(diceWidth/2) - UInt32(diceWidth/4)))
            let offset = UIOffsetMake(randomHorizontalOffset, randomVerticalOffset)
            dicePushBehavior.setTargetOffsetFromCenter(offset, forItem: diceView)
            animator.addBehavior(dicePushBehavior)
        }
    }
    
    //MARK: Motion Detection
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent) {
        if motion == UIEventSubtype.MotionShake {
            rollAllDice()
        }
    }
    
    
    //MARK: DiceViewDelegate
    func rollingFinishedOnDiceView(diceview : DiceView) {
        updateTotalLabel()
    }
    
    func tapOnDiceView(diceView: DiceView) {
        if diceViewInView.count == 1 {
            return
        }
        diceBehavior.removeItem(diceView)
        diceView.removeFromSuperview()
        updateTotalLabel()
    }
    
    //MARK: BottomViewDelegate
    func pressedButtonAddDice(bottomView: BottomView) {
        addNewDice()
    }
    
    func pressedButtonShake(bottomView: BottomView) {
        rollAllDice()
    }
    
}