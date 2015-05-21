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

class ViewController: UIViewController, BottomViewDelegate, JW3DDiceViewDelegate {
    
    var diceView : JW3DDiceView?
    var bottomView : BottomView!
    let animationBottomViewDuration = NSTimeInterval(0.5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        setUpDiceView()
        setUpBottomView()
        animateBottomView()
    }
    final private func setUpBottomView() {
        bottomView = BottomView(frame: bottomViewHiddenFrame)
        bottomView.delegate = self
        updateTotalLabel()
        view.addSubview(bottomView)
    }
    final private func setUpDiceView() {
        diceView = JW3DDiceView(frame: CGRectMake(0, 0, screenWidth, screenHeight - bottomViewHeight))
        diceView?.delegate = self
        view.addSubview(diceView!)
    }
}

//MARK: Animations
extension ViewController {

    final private func animateBottomView() {
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.TransitionNone, animations: {self.bottomView.frame = bottomViewNormalFrame}, completion: {(complete : Bool) in self.pop(self.bottomView.buttonShake)})
    }
    final private func updateTotalLabel() {
        bottomView.labelTotal.text = "\(diceView!.total)"
        pop(self.bottomView.labelTotal)
    }
    final private func buttonAddDiceShouldEnable(bool : Bool) {
        bottomView.buttonAddDice.enabled = bool
        pop(bottomView.buttonAddDice)
    }
    final private func buttonShakeShouldEnable(bool : Bool) {
        bottomView.buttonShake.enabled = bool
        pop(bottomView.buttonShake)
    }
    final func pop(view : UIView) {
        view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001)
        UIView.animateWithDuration(0.2/1.5, animations: {view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1)}, completion: {(complete : Bool) in
            UIView.animateWithDuration(0.2/2, animations: {view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9)}, completion: {(complete : Bool) in
                UIView.animateWithDuration(0.2/2, animations: {view.transform = CGAffineTransformIdentity
                })
            })
        })}
}

//MARK: JW3DDiceViewDelegate
extension ViewController {
    
    final func diceViewDidReachMaxDiceCount(diceView: JW3DDiceView) {
        buttonAddDiceShouldEnable(false)
    }
    final func diceViewDidGoUnderMaxDiceCount(diceView: JW3DDiceView) {
        buttonAddDiceShouldEnable(true)
    }
    final func diceViewDidStartRolling(diceView:JW3DDiceView) {
        buttonShakeShouldEnable(false)
    }
    final func diceViewDidEndRolling(diceView:JW3DDiceView) {
        buttonShakeShouldEnable(true)
        updateTotalLabel()
    }
    final func diceViewDidAddDice(diceView:JW3DDiceView) {
        updateTotalLabel()
    }
    final func diceViewDidDeleteDice(diceView:JW3DDiceView) {
        updateTotalLabel()
    }
}

//MARK: BottomViewDelegate
extension ViewController {
    
    final func pressedButtonAddDice(bottomView: BottomView) {
        pop(bottomView.buttonAddDice)
        diceView?.addDice()
    }
    final func pressedButtonShake(bottomView: BottomView) {
        diceView?.roll()
    }
}