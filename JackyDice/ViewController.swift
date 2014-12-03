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

let diceWidth = CGFloat(60)

let screenWidth = UIScreen.mainScreen().bounds.width
let screenHeight = UIScreen.mainScreen().bounds.height

let bottomViewHeight = screenHeight/10
let bottomViewWidth = screenWidth

let bottomViewHiddenFrame = CGRectMake(0, screenHeight, bottomViewWidth, bottomViewHeight)
let bottomViewNormalFrame = CGRectMake(0, screenHeight - bottomViewHeight,bottomViewWidth, bottomViewHeight)
let bottomViewDuringAdFrame = CGRectMake(0, adShowingFrame.origin.y - bottomViewHeight, bottomViewWidth, bottomViewHeight)

let adHeight = CGFloat(50)
let adHiddenFrame = CGRectMake(0, screenHeight, screenWidth, adHeight)
let adShowingFrame = CGRectMake(0, screenHeight - adHeight, screenWidth, adHeight)


//MARK: Global Functions

func delayClosureWithTime(delay : Double, closure: () -> ()) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
}

func afterAnimationCompleteDoClosure(animation:()->(), closure:()->()) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(closure)
    animation()
    CATransaction.commit()
}

func animateViewPop(view : UIView) {
    view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001)
    UIView.animateWithDuration(0.3/1.5, animations: {view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1)}, completion: {(complete : Bool) in
        UIView.animateWithDuration(0.3/2, animations: {view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9)}, completion: {(complete : Bool) in
            UIView.animateWithDuration(0.3/2, animations: {view.transform = CGAffineTransformIdentity
            })
        })
    })}

class ViewController: UIViewController, DiceViewDelegate, BottomViewDelegate, ADBannerViewDelegate {
    
    //MARK: UI Properties
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
        animateBottomView()
        setUpDiceLimit()
        setUpUIDynamics()
        setUpAdBannerView()
    }
    
    private func setUpBackground() {
        var backgroundImageView = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImageView.image = UIImage(named: "pokerTableFelt.jpg")
        backgroundImageView.contentMode = .ScaleAspectFill
        view.addSubview(backgroundImageView)
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
        animator = UIDynamicAnimator(referenceView: self.view)
        setUpCollisionBoundaries()
        animator.addBehavior(diceBehavior)
    }
    
    private func setUpCollisionBoundaries() {
        diceBehavior.collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        diceBehavior.collisionBehavior.addBoundaryWithIdentifier("bottomViewBorder",fromPoint: bottomViewNormalFrame.origin, toPoint: CGPointMake(bottomViewNormalFrame.origin.x + screenWidth, bottomViewNormalFrame.origin.y))
    }

    private func setUpMotionManager() {
        calibrateMultiplyConstat()
        var deviceMotionHandler : CMDeviceMotionHandler = {data, error in
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
    
    //MARK: Dice Functions
    
    private func addNewDice() {
        addNewDiceInView()
        updateTotalLabel()
        if diceViewInView.count >= diceNumberLimitRounded  {
            buttonAddDiceShouldEnable(false)
        }
    }
    
    private func addNewDiceInView() {
        playSoundEffect()
        let diceViewXposition = Int(arc4random_uniform(UInt32(screenWidth - diceWidth)))
        var diceView = DiceView(frame: CGRectMake(CGFloat(diceViewXposition), 0, diceWidth, diceWidth))
        diceView.delegate = self
        diceView.displayAndSetNumber(1)
        view.addSubview(diceView)
        diceBehavior.addItem(diceView)
        delayClosureWithTime(0.5, {self.diceBehavior.gravityBehavior.removeItem(diceView)})
    }

    private func rollAllDice() {
        bottomView.buttonShake.enabled = false
        playSoundEffect()
        animateDicePush()
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            delayClosureWithTime(0.25) {self.updateTotalLabel()}
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
        spinAnimation.cumulative = true
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
        diceBehavior.collisionBehavior.removeBoundaryWithIdentifier("bottomViewShowAdBoundary")
        
        for diceView in diceViewInView {
            if diceView.frame.origin.y >= (bottomViewDuringAdFrame.origin.y - diceWidth) {
                pushView(diceView, angle: CGFloat(3 * M_PI_2), offset: UIOffsetZero, magnitude: 5)
            }
        }

        delayClosureWithTime(0.5) {
            self.diceBehavior.collisionBehavior.addBoundaryWithIdentifier("bottomViewShowAdBoundary", fromPoint: bottomViewDuringAdFrame.origin, toPoint: CGPointMake(bottomViewDuringAdFrame.origin.x + screenWidth,bottomViewDuringAdFrame.origin.y))
            UIView.animateWithDuration(self.adAnimationDuration,
                animations: {
                    self.bottomView.frame = bottomViewDuringAdFrame
                    self.adBannerView.frame = adShowingFrame
            })
            
        }
    }
    
    func hideAd() {
        diceBehavior.collisionBehavior.removeBoundaryWithIdentifier("bottomViewShowAdBoundary")
        UIView.animateWithDuration(adAnimationDuration,
            animations: {
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
        afterAnimationCompleteDoClosure({
            self.animateDiceSpin(diceView, duration: 0.25)}) {
                if self.bottomView.buttonAddDice.enabled == false {
                    self.buttonAddDiceShouldEnable(true)
                }
                self.diceBehavior.removeItem(diceView)
                diceView.removeFromSuperview()
                self.updateTotalLabel()
        }
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
    
    //MARK: Testing Functions
    
    func testingAddFullDice() {
        while diceViewInView.count < diceNumberLimitRounded {
            self.addNewDice()
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