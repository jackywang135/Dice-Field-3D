//
//  ViewController.swift
//  JackyDice
//
//  Created by JackyWang on 11/19/14.
//  Copyright (c) 2014 JackyWang. All rights reserved.
//

import UIKit
import AVFoundation

//MARK: Global Variables

let screenWidth = UIScreen.mainScreen().bounds.width
let screenHeight = UIScreen.mainScreen().bounds.height

let diceWidth = CGFloat(60)

//MARK: Global Functions

func delayClosureWithTime(delay : Double, closure: () -> ()) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
}

func performClosureAfterAnimationFinish(animation:()->(), closure:()->()) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(closure)
    animation()
    CATransaction.commit()
}

class ViewController: UIViewController, DiceViewDelegate, BottomViewDelegate {
    
    //MARK: UI
    var bottomView : BottomView!
    
    //MARK: UIDynamicKit
    var animator : UIDynamicAnimator!
    var diceBehavior = DiceDynamicBehavior()
    
    //MARK: Sound 
    var shakeAndRollSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("ShakeAndRollDice", ofType: "mp3")!)
    var audioPlayer = AVAudioPlayer()

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
    
    //MARK: Functions
    
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

    func setUpUI() {
        setUpBackground()
        setUpBottomView()
        setUpDiceAnimateImage()
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
        let animationDuration = NSTimeInterval(0.5)
        UIView.transitionWithView(self.bottomView.labelTotal, duration: animationDuration, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: {self.bottomView.labelTotal.text = "\(self.total)" }, completion: nil)
    }
    
    func setUpUIDynamics() {
        animator = UIDynamicAnimator(referenceView: self.view)
        diceBehavior.collisionBehavior.addBoundaryWithIdentifier("shakeButtonBorder",fromPoint: bottomView.frame.origin, toPoint: CGPointMake(screenWidth, screenHeight - bottomViewHeight))
        animator.addBehavior(diceBehavior)
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
        playSoundEffect()
        animateDicePush()
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.updateTotalLabel()
        })
        for diceView in diceViewInView {
            diceView.roll()
        }
        CATransaction.commit()
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
    
    //MARK: Sound effect 
    
    func playSoundEffect() {
        audioPlayer = AVAudioPlayer(contentsOfURL: shakeAndRollSound, error: nil)
        audioPlayer.play()
    }
    
    //MARK: DiceViewDelegate
    
    func tapOnDiceView(diceView: DiceView) {
        if diceViewInView.count == 1 {
            return
        }
        diceBehavior.removeItem(diceView)
        diceView.removeFromSuperview()
        updateTotalLabel()
    }
    
    var diceAnimateImage = [UIImage]()
    
    func setUpDiceAnimateImage() {
        var diceImageArray = [UIImage]()
        for index in 1...13 {
            diceImageArray.append(UIImage(named: "dice\(index)")!)
        }
        diceAnimateImage = diceImageArray
    }
    
    func getDiceAnimateImageForDiceView(diceView : DiceView) -> [UIImage]{
        return diceAnimateImage
    }
    
    //MARK: BottomViewDelegate
    
    func pressedButtonAddDice(bottomView: BottomView) {
        addNewDice()
    }
    
    func pressedButtonShake(bottomView: BottomView) {
        rollAllDice()
    }
}