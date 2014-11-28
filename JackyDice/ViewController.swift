//
//  ViewController.swift
//  JackyDice
//
//  Created by JackyWang on 11/19/14.
//  Copyright (c) 2014 JackyWang. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion

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
    
    //MARK: UI Properties
    var bottomView : BottomView!
    var diceNumberLimitRounded = 10
    var diceImageHelper : DiceImageHelper?
    
    //MARK: UIDynamicKit Properties
    var animator : UIDynamicAnimator!
    var diceBehavior = DiceDynamicBehavior()
    var motionManager = CMMotionManager()
    
    
    //MARK: Audio Properties
    var shakeAndRollSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("ShakeAndRollDice", ofType: "mp3")!)
    var audioPlayer = AVAudioPlayer()
    var audioSession = AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient, error: nil)

    //MARK: Collection & Total Properties
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
    
    override func loadView() {
        super.loadView()
        diceImageHelper = DiceImageHelper()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        diceImageHelper = DiceImageHelper()
        setUpUI()
        setUpMotionManager()
        delayClosureWithTime(1) {self.addNewDice()}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    //MARK: Set Up Functions

    private func setUpUI() {
        setUpBackground()
        setUpBottomView()
        setUpDiceLimit()
        setUpUIDynamics()
    }
    
    private let bottomViewHeight = screenHeight/10
    private let bottomViewWidth = screenWidth
    
    private func setUpBackground() {
        var backgroundImageView = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImageView.image = UIImage(named: "greenFelt")
        backgroundImageView.contentMode = .ScaleAspectFill
        view.addSubview(backgroundImageView)
    }
    
    private func setUpBottomView() {
        bottomView = BottomView(frame: CGRectMake(0, screenHeight - bottomViewHeight, bottomViewWidth, bottomViewHeight))
        bottomView.delegate = self
        updateTotalLabel()
        view.addSubview(bottomView)
    }
    
    private func setUpDiceLimit() {
        let spaceEachDiceNeeds = 7
        let diceNumberLimit = Int((screenWidth * screenHeight) / (diceWidth * diceWidth)) / spaceEachDiceNeeds
        diceNumberLimitRounded = diceNumberLimit / 5 * 5
    }
    
    private func setUpUIDynamics() {
        animator = UIDynamicAnimator(referenceView: self.view)
        setUpCollisionBoundaries()
        animator.addBehavior(diceBehavior)
    }
    
    private func setUpCollisionBoundaries() {
        diceBehavior.collisionBehavior.addBoundaryWithIdentifier("bottomViewBorder",fromPoint: bottomView.frame.origin, toPoint: CGPointMake(screenWidth, screenHeight - bottomViewHeight))
        diceBehavior.collisionBehavior.translatesReferenceBoundsIntoBoundary = true
    }

    private func setUpMotionManager() {
        
        var deviceMotionHandler : CMDeviceMotionHandler = {data, error in
            NSLog("\(self.animator.behaviors.count)")
            let rotationX = CGFloat(data.rotationRate.x)
            let rotationY = CGFloat(data.rotationRate.y)
            let rotationZ = CGFloat(data.rotationRate.z)
            let accelerateX = CGFloat(data.userAcceleration.x)
            let accelerateY = CGFloat(data.userAcceleration.y)
            self.diceMotionHandler(rotationX, rotationY: rotationY, rotationZ: rotationZ, accelerateX: accelerateX, accelerateY: accelerateY)
        }
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: deviceMotionHandler)
    }
    
    func diceMotionHandler(rotationX : CGFloat, rotationY : CGFloat, rotationZ : CGFloat, accelerateX : CGFloat, accelerateY : CGFloat) {
        for diceView in diceViewInView {
            diceBehavior.dynamicItemBehavior.addLinearVelocity(CGPointMake(rotationY * 100, rotationX * 100), forItem: diceView)
            diceBehavior.dynamicItemBehavior.addAngularVelocity(-rotationZ, forItem: diceView)
            diceBehavior.dynamicItemBehavior.addLinearVelocity(CGPointMake(accelerateX * 500, accelerateY * 500), forItem: diceView)
        }
    }

    //MARK: UI Update Animations
    
    let animationBottomViewDuration = NSTimeInterval(0.5)
    
    private func updateTotalLabel() {
        UIView.transitionWithView(self.bottomView.labelTotal, duration: animationBottomViewDuration, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: {self.bottomView.labelTotal.text = "\(self.total)" }, completion: nil)
    }
    
    private func buttonAddDiceShouldEnable(bool : Bool) {
        UIView.transitionWithView(bottomView.buttonAddDice, duration: animationBottomViewDuration, options:UIViewAnimationOptions.TransitionFlipFromLeft, animations: {self.bottomView.buttonAddDice.enabled = bool}, completion: nil)
    }
    
    //MARK: Dice Functions
    
    private func addNewDice() {
        func diceLimitReached() -> Bool {
            if diceViewInView.count >= diceNumberLimitRounded {
                return true
            }
            return false
        }
        addNewDiceInView()
        updateTotalLabel()
        if diceLimitReached() {
            buttonAddDiceShouldEnable(false)
        }
    }
    
    private func addNewDiceInView() {
        playSoundEffect()
        let screenWidth = UIScreen.mainScreen().bounds.width
        let diceViewXposition = Int(arc4random_uniform(UInt32(screenWidth - diceWidth)))
        var diceView = DiceView(frame: CGRectMake(CGFloat(diceViewXposition), 0, diceWidth, diceWidth))
        diceView.delegate = self
        diceView.displayAndSetNumber(1)
        view.addSubview(diceView)
        diceBehavior.addItem(diceView)
    }

    private func rollAllDice() {
        setUpCollisionBoundaries()
        bottomView.buttonShake.enabled = false
        playSoundEffect()
        animateDicePush()
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.updateTotalLabel()
            self.bottomView.buttonShake.enabled = true
        })
        for diceView in diceViewInView {
            diceView.roll()
        }
        CATransaction.commit()
    }
    
    //MARK: Animation
    
    private func animateDicePush() {
        
        func getRandomRadians() -> CGFloat {
            return CGFloat(arc4random_uniform(UInt32(2*M_PI)))
        }
        func getRandomOffset() -> UIOffset {
            let randomHorizontalOffset = CGFloat(arc4random_uniform(UInt32(diceWidth/2) - UInt32(diceWidth/4)))
            let randomVerticalOffset = CGFloat(arc4random_uniform(UInt32(diceWidth/2) - UInt32(diceWidth/4)))
            return UIOffsetMake(randomHorizontalOffset, randomVerticalOffset)
        }
        
        for diceView in diceViewInView {
            var dicePushBehavior = UIPushBehavior(items:[diceView], mode: UIPushBehaviorMode.Instantaneous)
            dicePushBehavior.magnitude = 5
            dicePushBehavior.angle = getRandomRadians()
            dicePushBehavior.active = true
            dicePushBehavior.addItem(diceView)
            dicePushBehavior.setTargetOffsetFromCenter(getRandomOffset(), forItem: diceView)
            animator.addBehavior(dicePushBehavior)
            delayClosureWithTime(1){ self.animator.removeBehavior(dicePushBehavior)}
        }
    }
    
    //MARK: Motion Detection
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent) {
        if motion == UIEventSubtype.MotionShake {
            rollAllDice()
        }
    }
    
    //MARK: Sound effect 
    
    private func playSoundEffect() {
        audioPlayer = AVAudioPlayer(contentsOfURL: shakeAndRollSound, error: nil)
        audioPlayer.play()
    }
    
    //MARK: DiceViewDelegate
    
    func tapOnDiceView(diceView: DiceView) {
        func onlyOneDiceLeft() -> Bool {
            if diceViewInView.count == 1 {
                return true
            }
            return false
        }
        if onlyOneDiceLeft() {
            return
        }
        if bottomView.buttonAddDice.enabled == false {
            buttonAddDiceShouldEnable(true)
        }
        diceBehavior.removeItem(diceView)
        diceView.removeFromSuperview()
        updateTotalLabel()
    }
    
    func getDiceAnimateImageForDiceView(diceView : DiceView) -> [UIImage]{
        return diceImageHelper!.diceAnimateImage
    }
    
    func getDiceImageForDiceView(diceView:DiceView, num : Int) -> UIImage {
        return diceImageHelper!.getDiceImageForNumber(num)
    }
    
    //MARK: BottomViewDelegate
    
    func pressedButtonAddDice(bottomView: BottomView) {
        addNewDice()
    }
    
    func pressedButtonShake(bottomView: BottomView) {
        rollAllDice()
    }
}