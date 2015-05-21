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

class ViewController: UIViewController, BottomViewDelegate, ADBannerViewDelegate, JW3DDiceViewDelegate {
    
    var diceView : JW3DDiceView?
    var bottomView : BottomView!
    var adBannerView : ADBannerView!
    let animationBottomViewDuration = NSTimeInterval(0.5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        diceView = JW3DDiceView(frame: CGRectMake(0, 0, screenWidth, screenHeight - bottomViewHeight))
        diceView?.delegate = self
        view.addSubview(diceView!)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
        setUpUI()
        delay(1) {diceView?.addDice()}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    override func shouldAutorotate() -> Bool {
        return false
    }
}

//MARK: SetUp
extension ViewController {

    final private func setUpUI() {
        setUpBottomView()
        setUpAdBannerView()
        animateBottomView()
    }
    final private func setUpBottomView() {
        bottomView = BottomView(frame: bottomViewHiddenFrame)
        bottomView.delegate = self
        updateTotalLabel()
        view.addSubview(bottomView)
    }
    final private func setUpAdBannerView() {
        adBannerView = ADBannerView(frame:adHiddenFrame)
        adBannerView.delegate = self
        view.addSubview(adBannerView)
    }
}

//MARK: Animations
extension ViewController {

    final private func animateBottomView() {
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.TransitionNone, animations: {self.bottomView.frame = bottomViewNormalFrame}, completion: {(complete : Bool) in self.animateViewPop(self.bottomView.buttonShake)})
    }
    
    final private func updateTotalLabel() {
        bottomView.labelTotal.text = "\(diceView!.total)"
        animateViewPop(self.bottomView.labelTotal)
    }
    
    final private func buttonAddDiceShouldEnable(bool : Bool) {
        self.bottomView.buttonAddDice.enabled = bool
        animateViewPop(bottomView.buttonAddDice)
    }
    
    final private func buttonShakeShouldEnable(bool : Bool) {
        self.bottomView.buttonShake.enabled = bool
        animateViewPop(bottomView.buttonShake)
    }
    
    final func animateDiceSpin(diceView : UIView, duration: Double) {
        var spinAnimation = CABasicAnimation()
        spinAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        spinAnimation.toValue = 2 * M_PI
        spinAnimation.duration = duration
        spinAnimation.cumulative = false
        spinAnimation.repeatCount = 1
        diceView.layer.addAnimation(spinAnimation, forKey: "spinAnimation")
    }
    
    final func showAd() {
        UIView.animateWithDuration(0.5,
            animations: {
                self.diceView?.frame = animatorViewDuringAdFrame
                self.bottomView.frame = bottomViewDuringAdFrame
                self.adBannerView.frame = adShowingFrame
        })
    }
    
    final func hideAd() {
        UIView.animateWithDuration(0.5,
            animations: {
                self.diceView?.frame = animatorViewHideAdFrame
                self.bottomView.frame = bottomViewNormalFrame
                self.adBannerView.frame = adHiddenFrame
        })
    }
    final func animateViewPop(view : UIView) {
        view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001)
        UIView.animateWithDuration(0.2/1.5, animations: {view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1)}, completion: {(complete : Bool) in
            UIView.animateWithDuration(0.2/2, animations: {view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9)}, completion: {(complete : Bool) in
                UIView.animateWithDuration(0.2/2, animations: {view.transform = CGAffineTransformIdentity
                })
            })
        })}
}

//MARK: ADBannerViewDelegate
extension ViewController {

    final func bannerViewDidLoadAd(banner: ADBannerView!) {
        showAd()
    }
    
    final func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    
    final func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        hideAd()
    }
}

//MARK: JW3DDiceViewDelegate
extension ViewController {
    
    func diceViewDidReachMaxDiceCount(diceView: JW3DDiceView) {
        buttonAddDiceShouldEnable(false)
    }
    func diceViewDidGoUnderMaxDiceCount(diceView: JW3DDiceView) {
        buttonAddDiceShouldEnable(true)
    }
    func diceViewDidStartRolling(diceView:JW3DDiceView) {
        buttonShakeShouldEnable(false)
    }
    func diceViewDidEndRolling(diceView:JW3DDiceView) {
        buttonShakeShouldEnable(true)
        updateTotalLabel()
    }
    func diceViewDidAddDice(diceView:JW3DDiceView) {
        updateTotalLabel()
    }
    func diceViewDidDeleteDice(diceView:JW3DDiceView) {
        updateTotalLabel()
    }
}

//MARK: BottomViewDelegate
extension ViewController {
    
    final func pressedButtonAddDice(bottomView: BottomView) {
        animateViewPop(bottomView.buttonAddDice)
        diceView?.addDice()
    }
    final func pressedButtonShake(bottomView: BottomView) {
        diceView?.roll()
    }
}

//MARK: iAd Testing
extension ViewController {

    final func testingButtonsForiAd() {
        let diceWidth = diceView!.diceWidth
        var buttonShowAd = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        buttonShowAd.setTitle("S", forState: UIControlState.Normal)
        buttonShowAd.frame = CGRectMake(screenWidth - diceWidth, 0, diceWidth, diceWidth)
        buttonShowAd.addTarget(self, action: "showAd", forControlEvents: UIControlEvents.TouchUpInside)
        
        var buttonHideAd = UIButton.buttonWithType(UIButtonType.System) as! UIButton
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