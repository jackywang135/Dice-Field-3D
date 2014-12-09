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
import iAd

//MARK: Global Variables

let bottomViewHeight = screenHeight/10
let bottomViewWidth = screenWidth

let bottomViewHiddenFrame = CGRectMake(0, screenHeight, bottomViewWidth, bottomViewHeight)
let bottomViewNormalFrame = CGRectMake(0, screenHeight - bottomViewHeight,bottomViewWidth, bottomViewHeight)
let bottomViewDuringAdFrame = CGRectMake(0, adShowingFrame.origin.y - bottomViewHeight, bottomViewWidth, bottomViewHeight)

let adHeight = CGFloat(50)
let adHiddenFrame = CGRectMake(0, screenHeight, screenWidth, adHeight)
let adShowingFrame = CGRectMake(0, screenHeight - adHeight, screenWidth, adHeight)

let animatorViewDuringAdFrame = CGRectMake(0, 0, screenWidth, screenHeight - bottomViewHeight - adHeight)
let animatorViewHideAdFrame = CGRectMake(0, 0, screenWidth, screenHeight - bottomViewHeight)

class ViewController: UIViewController, DiceViewDelegate, BottomViewDelegate, ADBannerViewDelegate {
    
    //MARK: UI Properties
    var animatorView : UIView!
    var bottomView : BottomView!
    var adBannerView : ADBannerView!
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
            for view in animatorView.subviews {
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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
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
        setUpAnimatorView()
        setUpBottomView()
        setUpAdBannerView()
        setUpDiceLimit()
        setUpUIDynamics()
        animateBottomView()
        //testingButtonsForiAd()
    }
    
    private func setUpBackground() {
        var backgroundImageView = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImageView.image = UIImage(named: "pokerTableFelt.jpg")
        backgroundImageView.contentMode = .ScaleAspectFill
        view.addSubview(backgroundImageView)
    }
    
    func setUpAnimatorView() {
        animatorView = UIView(frame: CGRectMake(0, 0, screenWidth, screenHeight - bottomViewHeight))
        view.addSubview(animatorView)
    }
    
    private func setUpBottomView() {
        bottomView = BottomView(frame: bottomViewHiddenFrame)
        bottomView.delegate = self
        updateTotalLabel()
        view.addSubview(bottomView)
    }
    
    private func animateBottomView() {
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.TransitionNone, animations: {self.bottomView.frame = bottomViewNormalFrame}, completion: {(complete : Bool) in animateViewPop(self.bottomView.buttonShake)})
    }
    
    private func setUpDiceLimit() {
        let spaceEachDiceNeeds = 7
        let diceNumberLimit = Int((screenWidth * screenHeight) / (diceWidth * diceWidth)) / spaceEachDiceNeeds
        diceNumberLimitRounded = diceNumberLimit / 5 * 5
    }
    
    private func setUpUIDynamics() {
        animator = UIDynamicAnimator(referenceView: animatorView)
        diceBehavior.collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(diceBehavior)
    }

    private func setUpMotionManager() {
        calibrateMultiplyConstat()
        var deviceMotionHandler : CMDeviceMotionHandler = {data, error in
            let rotationX = CGFloat(data.rotationRate.x)
            let rotationY = CGFloat(data.rotationRate.y)
            let rotationZ = CGFloat(data.rotationRate.z)
            let accelerateX = CGFloat(data.userAcceleration.x)
            let accelerateY = CGFloat(data.userAcceleration.y)
            
            let accelerateLimit = CGFloat(2)
            let rotationLimit = CGFloat(6)
            if accelerateX > accelerateLimit || accelerateY > accelerateLimit || rotationX > rotationLimit || rotationY > rotationLimit || rotationZ > rotationLimit {
                self.rollAllDice()
            } else {
                self.diceMotionHandler(rotationX, rotationY: rotationY, rotationZ: rotationZ, accelerateX: accelerateX, accelerateY: accelerateY)
            }
        }
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: deviceMotionHandler)
    }
    
    var multiplyConstant = CGFloat(100)
    
    func calibrateMultiplyConstat() {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            multiplyConstant = multiplyConstant * 1.5
        }
    }
    
    func diceMotionHandler(rotationX : CGFloat, rotationY : CGFloat, rotationZ : CGFloat, accelerateX : CGFloat, accelerateY : CGFloat) {
        for diceView in diceViewInView {
            diceBehavior.dynamicItemBehavior.addLinearVelocity(CGPointMake(rotationY * multiplyConstant, rotationX * multiplyConstant), forItem: diceView)
            diceBehavior.dynamicItemBehavior.addAngularVelocity(-rotationZ, forItem: diceView)
            diceBehavior.dynamicItemBehavior.addLinearVelocity(CGPointMake(accelerateX * multiplyConstant, accelerateY * multiplyConstant), forItem: diceView)
        }
    }
    
    func setUpAdBannerView() {
        adBannerView = ADBannerView(frame:adHiddenFrame)
        adBannerView.delegate = self
        view.addSubview(adBannerView)
    }
    
    //MARK: UI Update Animations
    
    let animationBottomViewDuration = NSTimeInterval(0.5)
    
    private func updateTotalLabel() {
        bottomView.labelTotal.text = "\(self.total)"
        animateViewPop(self.bottomView.labelTotal)
    }
    
    private func buttonAddDiceShouldEnable(bool : Bool) {
        self.bottomView.buttonAddDice.enabled = bool
        animateViewPop(bottomView.buttonAddDice)
    }
    
    private func buttonShakeShouldEnable(bool : Bool) {
        self.bottomView.buttonShake.enabled = bool
        animateViewPop(bottomView.buttonShake)
    }
    
    //MARK: Dice Functions
    
    private func addNewDice() {
        playSoundEffect()
        addNewDiceInView()
        updateTotalLabel()
        if diceViewInView.count >= diceNumberLimitRounded  {
            buttonAddDiceShouldEnable(false)
        }
    }
    
    private func addNewDiceInView() {
        let diceViewXposition = Int(arc4random_uniform(UInt32(screenWidth - diceWidth)))
        var diceView = DiceView(frame: CGRectMake(CGFloat(diceViewXposition), 0, diceWidth, diceWidth))
        diceView.delegate = self
        diceView.displayAndSetNumber(1)
        animatorView.addSubview(diceView)
        diceBehavior.addItem(diceView)
        delayClosureWithTime(0.5, {self.diceBehavior.gravityBehavior.removeItem(diceView)})
    }

    private func rollAllDice() {
        buttonShakeShouldEnable(false)
        playSoundEffect()
        animateDicePush()
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            delayClosureWithTime(0.2) {
            self.updateTotalLabel()
            self.buttonShakeShouldEnable(true)
            }
        })
        for diceView in diceViewInView {
            diceView.roll()
        }
        CATransaction.commit()
    }
    
    //MARK: Animation
    
    private func animateDicePush() {
        
        func getRandomRadians() -> CGFloat {
            return CGFloat(arc4random_uniform(UInt32(2 * M_PI)))
        }
        func getRandomOffset() -> UIOffset {
            let randomHorizontalOffset = CGFloat(arc4random_uniform(UInt32(diceWidth/2) - UInt32(diceWidth/4)))
            let randomVerticalOffset = CGFloat(arc4random_uniform(UInt32(diceWidth/2) - UInt32(diceWidth/4)))
            return UIOffsetMake(randomHorizontalOffset, randomVerticalOffset)
        }
        
        for diceView in diceViewInView {
            pushView(diceView, angle: getRandomRadians(), offset: getRandomOffset(), magnitude: 5)
        }
    }
    
    func pushView(view: UIView, angle: CGFloat, offset:UIOffset, magnitude: CGFloat) {
        var dicePushBehavior = UIPushBehavior(items:[view], mode: UIPushBehaviorMode.Instantaneous)
        dicePushBehavior.magnitude = magnitude
        dicePushBehavior.angle = angle
        dicePushBehavior.active = true
        dicePushBehavior.addItem(view)
        dicePushBehavior.setTargetOffsetFromCenter(offset, forItem: view)
        animator.addBehavior(dicePushBehavior)
        delayClosureWithTime(1){ self.animator.removeBehavior(dicePushBehavior)}
    }
    
//    func animateDiceShrink(diceView : UIView, duration: Double){
//        UIView.animateWithDuration(duration, animations: {
//            var shrinkFrame = CGRectMake(diceView.center.x, diceView.center.y, 0, 0)
//            diceView.frame = shrinkFrame
//            }, completion: nil)
//    }
    
    func animateDiceSpin(diceView : UIView, duration: Double) {
        var spinAnimation = CABasicAnimation()
        spinAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        spinAnimation.toValue = 2 * M_PI
        spinAnimation.duration = duration
        spinAnimation.cumulative = false
        spinAnimation.repeatCount = 1
        diceView.layer.addAnimation(spinAnimation, forKey: "spinAnimation")
    }
    
//    func animateDiceOpacity(diceView : UIView, duration : Double) {
//        var opacityAnimation = CABasicAnimation()
//        opacityAnimation = CABasicAnimation(keyPath: "opacity")
//        opacityAnimation.toValue = 0
//        opacityAnimation.duration = duration
//        diceView.layer.addAnimation(opacityAnimation, forKey: "opacityAnimation")
//    }
    
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
    
    //MARK: iAd Delegate
    
    let adAnimationDuration = 0.5
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        showAd()
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        hideAd()
    }
    
    func showAd() {
        UIView.animateWithDuration(self.adAnimationDuration,
            animations: {
                self.animatorView.frame = animatorViewDuringAdFrame
                self.bottomView.frame = bottomViewDuringAdFrame
                self.adBannerView.frame = adShowingFrame
        })
    }
    
    func hideAd() {
        UIView.animateWithDuration(adAnimationDuration,
            animations: {
                self.animatorView.frame = animatorViewHideAdFrame
                self.bottomView.frame = bottomViewNormalFrame
                self.adBannerView.frame = adHiddenFrame
        })
    }
 
    //MARK: DiceViewDelegate
    
    func tapOnDiceView(diceView: DiceView) {
        if diceViewInView.count == 1 {
            self.animateDiceSpin(diceView, duration: 0.25)
            return
        }
        
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.diceBehavior.removeItem(diceView)
            diceView.removeFromSuperview()
            if self.bottomView.buttonAddDice.enabled == false {
                self.buttonAddDiceShouldEnable(true)
            }
            self.updateTotalLabel()
        })
        self.animateDiceSpin(diceView, duration: 0.25)
        CATransaction.commit()
    }
    
    func getDiceAnimateImageForDiceView(diceView : DiceView) -> [UIImage]{
        return diceImageHelper!.diceAnimateImage
    }
    
    func getDiceImageForDiceView(diceView:DiceView, num : Int) -> UIImage {
        return diceImageHelper!.getDiceImageForNumber(num)
    }
    
    //MARK: BottomViewDelegate
    
    func pressedButtonAddDice(bottomView: BottomView) {
        animateViewPop(bottomView.buttonAddDice)
        addNewDice()
    }
    
    func pressedButtonShake(bottomView: BottomView) {
        rollAllDice()
    }
    
    //MARK: Testing Functions
    
    func testingAddFullDice() {
        while diceViewInView.count < diceNumberLimitRounded {
            addNewDice()
        }
    }
    
    func testingButtonsForiAd() {
        var buttonShowAd = UIButton.buttonWithType(UIButtonType.System) as UIButton
        buttonShowAd.setTitle("S", forState: UIControlState.Normal)
        buttonShowAd.frame = CGRectMake(screenWidth - diceWidth, 0, diceWidth, diceWidth)
        buttonShowAd.addTarget(self, action: "showAd", forControlEvents: UIControlEvents.TouchUpInside)
        
        var buttonHideAd = UIButton.buttonWithType(UIButtonType.System) as UIButton
        buttonHideAd.setTitle("H", forState: UIControlState.Normal)
        buttonHideAd.frame = CGRectMake(screenWidth - diceWidth * 2, 0, diceWidth, diceWidth)
        buttonHideAd.addTarget(self, action: "hideAd", forControlEvents: UIControlEvents.TouchUpInside)
        
        view.addSubview(buttonShowAd)
        view.addSubview(buttonHideAd)
        view.bringSubviewToFront(buttonShowAd)
        view.bringSubviewToFront(buttonHideAd)
        buttonHideAd.backgroundColor = UIColor.blackColor()
        buttonShowAd.backgroundColor = UIColor.blackColor()
        buttonHideAd.titleLabel!.textColor = UIColor.whiteColor()
        buttonShowAd.titleLabel!.textColor = UIColor.whiteColor()
    }
}