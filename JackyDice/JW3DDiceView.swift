//
//  JW3DDiceView.swift
//  JW3DDiceView
//
//  Created by Jacky Wang on 5/1/15.
//  Copyright (c) 2015 Jacky Wang. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion

protocol JW3DDiceViewDelegate {
    func diceViewDidReachMaxDiceCount(diceView: JW3DDiceView)
    func diceViewDidGoUnderMaxDiceCount(diceView: JW3DDiceView)
    func diceViewDidStartRolling(diceView:JW3DDiceView)
    func diceViewDidEndRolling(diceView:JW3DDiceView)
    func diceViewDidAddDice(diceView:JW3DDiceView)
    func diceViewDidDeleteDice(diceView:JW3DDiceView)
}

class JW3DDiceView: UIView, JW3DDiceDelegate {
    //Customizable properties
    var diceWidth: CGFloat = 60
    var diceCount: Int {
        get {
            return diceViews.count
        }
    }
    var maxDiceCount: Int
    var total: Int {
        get {
            return diceViews.reduce(0){$0 + $1.number}
        }
    }
    var shakeEnabled = true
    var deviceMotionEnabled = true {
        didSet {
            resetMotionManager()
        }
    }
    var soundEnabled = true
    var delegate: JW3DDiceViewDelegate?
    
    //Private
    private let defaultBackgroundImage = UIImage(named: "defaultBackground.jpg")
    private let diceMaxDensityInFrame : CGFloat = 1/7
    private let motionManager = CMMotionManager()
    private var animator : UIDynamicAnimator?
    private let diceBehavior = JWDiceDynamicBehavior()
    private var diceViews : [JW3DDice] {
        get {
            return subviews.filter() {$0 is JW3DDice} as! [JW3DDice]
        }
    }
    private var deviceMotionCalibration: CGFloat {
        get {
            return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 150 : 100
        }
    }
    private let audioPlayer = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("ShakeAndRollDice", ofType: "mp3")!), error: nil)
    
    override init(frame: CGRect) {
        maxDiceCount = 5
        super.init(frame: frame)
        initialSetUp()
    }
    required init(coder aDecoder: NSCoder) {
        maxDiceCount = 5
        super.init(coder: aDecoder)
        initialSetUp()
    }
    func initialSetUp() {
        setMaxCount()
        animator = UIDynamicAnimator(referenceView: self)
        animator?.addBehavior(diceBehavior)
        resetMotionManager()
        setBackgroundImage(defaultBackgroundImage!)
    }
    func setMaxCount() {
        maxDiceCount = Int(floor(diceMaxDensityInFrame * ((frame.height * frame.width) / (diceWidth * diceWidth))))
    }
    func setBackgroundImage(image: UIImage) {
        var backgroundImageView = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImageView.image = image
        backgroundImageView.contentMode = .ScaleAspectFill
        addSubview(backgroundImageView)
    }
}

//MARK: Dice Operations
extension JW3DDiceView {
    func addDice() {
        if diceCount == maxDiceCount {
            return
        }
        let diceViewXposition = Int(arc4random_uniform(UInt32(self.frame.width - diceWidth)))
        let dice = JW3DDice(frame: CGRectMake(CGFloat(diceViewXposition), 0, diceWidth, diceWidth))
        addSubview(dice)
        diceBehavior.addItem(dice)
        diceBehavior.delegate = dice
        dice.delegate = self
        playSound()
        delegate?.diceViewDidAddDice(self)
        delay(0.5) { self.diceBehavior.gravityBehavior.removeItem(dice)}
        if diceCount == maxDiceCount {
            delegate?.diceViewDidReachMaxDiceCount(self)
            return
        }
    }
    func deleteDice(dice: JW3DDice) {
        dice.removeFromSuperview()
        delegate?.diceViewDidDeleteDice(self)
        if diceCount == maxDiceCount - 1 {
            delegate?.diceViewDidGoUnderMaxDiceCount(self)
        }
    }
    func roll() {
        delegate?.diceViewDidStartRolling(self)
        pushDice()
        diceViews.map() { $0.roll()}
    }
    private func pushDice() {
        func getRandomRadians() -> CGFloat {
            return CGFloat(arc4random_uniform(UInt32(2 * M_PI)))
        }
        func getRandomOffset() -> UIOffset {
            let randomHorizontalOffset = CGFloat(arc4random_uniform(UInt32(diceWidth/2) - UInt32(diceWidth/4)))
            let randomVerticalOffset = CGFloat(arc4random_uniform(UInt32(diceWidth/2) - UInt32(diceWidth/4)))
            return UIOffsetMake(randomHorizontalOffset, randomVerticalOffset)
        }
        for dice in diceViews {
            var dicePushBehavior = UIPushBehavior(items:[dice], mode: UIPushBehaviorMode.Instantaneous)
            dicePushBehavior.magnitude = 5
            dicePushBehavior.angle = getRandomRadians()
            dicePushBehavior.active = true
            dicePushBehavior.addItem(dice)
            dicePushBehavior.setTargetOffsetFromCenter(getRandomOffset(), forItem: dice)
            animator?.addBehavior(dicePushBehavior)
            delay(1) { animator?.removeBehavior(dicePushBehavior) }
        }
    }
}
//MARK: JW3DiceDelegate
extension JW3DDiceView {
    func diceDidStartRolling(dice: JW3DDice) {
    
    }
    func diceDidEndRolling(dice: JW3DDice) {
        let activeDice = diceViews.filter(){$0.isAnimating()}
        if activeDice.count == 0 {
            self.delegate?.diceViewDidEndRolling(self)
        }
    }
    func diceDidReceiveTap(dice: JW3DDice) {
        if diceCount == 1 {
            return
        }
        deleteDice(dice)
    }
}
//MARK: Sound
extension JW3DDiceView {
    private func playSound() {
        if !soundEnabled {
            return
        }
        audioPlayer.play()
    }
}

//MARK: Shake Motion
extension JW3DDiceView {
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent) {
        if !shakeEnabled {
            return
        }
        if motion == UIEventSubtype.MotionShake {
            roll()
        }
    }
}

//MARK: Device Motion
extension JW3DDiceView {
    private func resetMotionManager() {
        if !deviceMotionEnabled {
            motionManager.stopDeviceMotionUpdates()
            return
        }
        var deviceMotionHandler : CMDeviceMotionHandler = {data, error in
            let rotationX = CGFloat(data.rotationRate.x)
            let rotationY = CGFloat(data.rotationRate.y)
            let rotationZ = CGFloat(data.rotationRate.z)
            let accelerateX = CGFloat(data.userAcceleration.x)
            let accelerateY = CGFloat(data.userAcceleration.y)
            
            let accelerateLimit = CGFloat(2)
            let rotationLimit = CGFloat(6)
            if accelerateX > accelerateLimit || accelerateY > accelerateLimit || rotationX > rotationLimit || rotationY > rotationLimit || rotationZ > rotationLimit {
                self.roll()
            } else {
                self.moveDice(rotationX, rotationY: rotationY, rotationZ: rotationZ, accelerateX: accelerateX, accelerateY: accelerateY)
            }
        }
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: deviceMotionHandler)
    }
    private func moveDice(rotationX : CGFloat, rotationY : CGFloat, rotationZ : CGFloat, accelerateX : CGFloat, accelerateY : CGFloat) {
        for dice in diceViews {
            diceBehavior.dynamicItemBehavior.addLinearVelocity(CGPointMake(rotationY * deviceMotionCalibration, rotationX * deviceMotionCalibration), forItem: dice)
            diceBehavior.dynamicItemBehavior.addAngularVelocity(-rotationZ, forItem: dice)
            diceBehavior.dynamicItemBehavior.addLinearVelocity(CGPointMake(accelerateX * deviceMotionCalibration, accelerateY * deviceMotionCalibration), forItem: dice)
        }
    }
}

protocol JW3DDiceDelegate {
    func diceDidStartRolling(dice: JW3DDice)
    func diceDidEndRolling(dice: JW3DDice)
    func diceDidReceiveTap(dice: JW3DDice)
}

internal class JW3DDice: UIImageView, JWDiceDynamicBehaviorDelegate {
    var number: Int{
        didSet {
            image = JWDiceImageHelper.sharedHelper.getDiceImage(number)
        }
    }
    private var insetValue : CGFloat
    var isRolling = false
    var didContact = false
    var delegate: JW3DDiceDelegate?
    var diceWidth: CGFloat {
        get {
            return self.frame.width
        }
    }

    override init(frame: CGRect) {
        insetValue = frame.width / 5
        number = 1
        super.init(frame: frame)
        image = JWDiceImageHelper.sharedHelper.getDiceImage(number)
        var tapGesture = UITapGestureRecognizer(target: self, action:"didTap:")
        addGestureRecognizer(tapGesture)
        userInteractionEnabled = true
    }
    required init(coder aDecoder: NSCoder) {
        insetValue = 0
        number = 1
        super.init(coder: aDecoder)
        insetValue = diceWidth / 5
        image = JWDiceImageHelper.sharedHelper.getDiceImage(number)
        var tapGesture = UITapGestureRecognizer(target: self, action:"didTap:")
        addGestureRecognizer(tapGesture)
        userInteractionEnabled = true
        
    }
    //Expand & shrink frame before & after animation because static image size is larger than animation images.
    
    func roll() {
        if isAnimating() {
            return
        }
        didContact = false
        animateWithCompletion({
            self.animateRoll()
            self.expandSizeWithInsetValue(self.insetValue)
            self.delegate?.diceDidStartRolling(self)
        }) {
            self.shrinkSizeWithInsetValue(self.insetValue)
            self.setRandomNumber()
            self.delegate?.diceDidEndRolling(self)
        }
        delay(1){
            self.stopAnimating()
        }
    }
    private func animateRoll() {
        animationImages = JWDiceImageHelper.sharedHelper.diceAnimateImage
        animationRepeatCount = 0
        startAnimating()
    }
    private func setRandomNumber() {
        number = Int(arc4random() % 6) + 1
    }
    private func shrinkSizeWithInsetValue(float : CGFloat) {
        self.bounds = CGRectInset(self.bounds, insetValue, insetValue)
    }
    private func expandSizeWithInsetValue(float: CGFloat) {
        self.bounds = CGRectInset(self.bounds, -insetValue, -insetValue)
    }
    func didTap(gesture:UITapGestureRecognizer) {
        delegate?.diceDidReceiveTap(self)
    }
    
    //MARK: JWDiceDynamicBehaviorDelegate
    func didCollide(dice:JW3DDice) {
        if !isAnimating() || didContact {
            return
        }
        dice.didContact = true
        delay(0.5){
            dice.stopAnimating()
        }
    }
}

protocol JWDiceDynamicBehaviorDelegate {
    func didCollide(dice:JW3DDice)
}
internal class JWDiceDynamicBehavior: UIDynamicBehavior, UICollisionBehaviorDelegate {
    var collisionBehavior = UICollisionBehavior()
    var dynamicItemBehavior = UIDynamicItemBehavior()
    var gravityBehavior = UIGravityBehavior()
    var delegate: JWDiceDynamicBehaviorDelegate?
    
    override init() {
        super.init()
        setUpBehaviors()
        addChildBehavior(collisionBehavior)
        addChildBehavior(dynamicItemBehavior)
        addChildBehavior(gravityBehavior)
    }
    func setUpBehaviors() {
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.collisionDelegate = self
        dynamicItemBehavior.elasticity = 0.45
        dynamicItemBehavior.resistance = 1
        dynamicItemBehavior.angularResistance = 1
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
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        if let dice = item1 as? JW3DDice {
            delegate?.didCollide(dice)
        }
        if let dice = item2 as? JW3DDice {
            delegate?.didCollide(dice)
        }
    }
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
        if let dice = item as? JW3DDice {
            gravityBehavior.removeItem(dice)
            delegate?.didCollide(dice)
        }
    }
}

internal class JWDiceImageHelper {
    //Getting the images from resources can be expensive when many dice are in the field. Therefore, only init the images once and allow access by all dice.
    var diceAnimateImage = [UIImage]()
    private var diceImage = [UIImage]()
    class var sharedHelper :JWDiceImageHelper {
        struct singleton {
            static let instance = JWDiceImageHelper()
        }
        return singleton.instance
    }
    init() {
        setUpDiceAnimateImage()
        setUpDiceImage()
    }
    private func setUpDiceAnimateImage() {
        var diceImageArray = [UIImage]()
        for index in 1...13 {
            diceImageArray.append(UIImage(named: "dice\(index)")!)
        }
        diceAnimateImage = diceImageArray
    }
    private func setUpDiceImage() {
        var diceImageArray = [UIImage]()
        for index in 1...6 {
            diceImageArray.append(UIImage(named: "\(index)")!)
        }
        diceImage = diceImageArray
    }
    
    func getDiceImage(num : Int) -> UIImage {
        return diceImage[(num - 1)] as UIImage
    }
}

func delay(delay: Double, closure: () -> ()) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
}
func animateWithCompletion(animation:()->(), completion:()->()) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    animation()
    CATransaction.commit()
}
