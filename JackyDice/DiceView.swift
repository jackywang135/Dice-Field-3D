//
//  DiceView.swift
//  JackyDice
//
//  Created by JackyWang on 11/20/14.
//  Copyright (c) 2014 JackyWang. All rights reserved.
//

import Foundation
import UIKit

protocol DiceViewDelegate {
    func tapOnDiceView(diceView : DiceView)
    func rollingFinishedOnDiceView(diceview : DiceView)
}

class DiceView : UIImageView {
    
    var delegate : DiceViewDelegate?
    
    var number : Int = 0
    var tapGesture : UITapGestureRecognizer?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        displayAndSetNumber(1)
        initTap()
        //setUpShadow()
    }
    
    func initTap() {
        tapGesture = UITapGestureRecognizer(target: self, action: "tap:")
        addGestureRecognizer(tapGesture!)
        userInteractionEnabled = true
    }
    
    func setUpShadow() {
        layer.shadowColor = UIColor.blackColor().CGColor
        //layer.shadowOffset = CGSizeMake(5, 5)
        //layer.shadowRadius = 5
        let shadowWidth = CGFloat(2)
        layer.shadowOpacity = 1.0
        layer.shadowPath = UIBezierPath(rect: CGRectMake(bounds.origin.x - shadowWidth, bounds.origin.y - shadowWidth, bounds.width + 2 * shadowWidth, bounds.height + 2 * shadowWidth)).CGPath
    }
    
    func tap(sender:UITapGestureRecognizer) {
        delegate!.tapOnDiceView(self)
    }
    
    func roll() {
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                self.shrinkSizeWithInsetValue(-10)
                self.displayAndSetNumber(self.getRandomDiceNumber())
                self.delegate!.rollingFinishedOnDiceView(self)
            })
            animateRolling()
            CATransaction.commit()

    }

    func getRandomDiceNumber() -> Int {
        return Int(arc4random() % 6) + 1
    }
    
    //MARK: Image
    
    func displayAndSetNumber(num:Int) {
        image = UIImage(named:"\(num)")
        number = num
    }
    
    //MARK: Animation

    var diceAnimateImage : [UIImage] {
        get {
            var diceImageArray = [UIImage]()
            for index in 1...13 {
                diceImageArray.append(UIImage(named: "dice\(index)")!)
            }
            return diceImageArray
        }
    }
    
    func animateRolling() {
        expandSizeWithInsetValue(-insetValue)
        animationImages = diceAnimateImage
        animationRepeatCount = 0
        startAnimating()
    }
    
    //MARK: Inset
    
    let insetValue = CGFloat(diceWidth * 1 / 6)
    
    func shrinkSizeWithInsetValue(float : CGFloat) {
        self.bounds = CGRectInset(self.bounds, insetValue, insetValue)
    }
    func expandSizeWithInsetValue(float: CGFloat) {
        self.bounds = CGRectInset(self.bounds, -insetValue, -insetValue)
    }
}