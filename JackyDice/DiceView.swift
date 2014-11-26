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
    func getDiceAnimateImageForDiceView(diceView : DiceView) -> [UIImage]
    func getDiceImageForDiceView(diceView:DiceView, num : Int) -> UIImage
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
        //displayAndSetNumber(1)
        initTap()
    }
    
    func initTap() {
        tapGesture = UITapGestureRecognizer(target: self, action: "tap:")
        addGestureRecognizer(tapGesture!)
        userInteractionEnabled = true
    }
    
    func tap(sender:UITapGestureRecognizer) {
        delegate!.tapOnDiceView(self)
    }
    
    func roll() {
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                self.shrinkSizeWithInsetValue(self.insetValue)
                self.displayAndSetNumber(self.getRandomDiceNumber())
            })
            animateRolling()
            CATransaction.commit()
    }

    func getRandomDiceNumber() -> Int {
        return Int(arc4random() % 6) + 1
    }
    
    //MARK: Image
    
    func displayAndSetNumber(n:Int) {
        image = delegate!.getDiceImageForDiceView(self, num: n)
        number = n
    }
    
    //MARK: Animation
    
    func animateRolling() {
        expandSizeWithInsetValue(insetValue)
        animationImages = delegate!.getDiceAnimateImageForDiceView(self)
        animationRepeatCount = 0
        startAnimating()
    }
    
    //MARK: Inset
    
    let insetValue = CGFloat(diceWidth * 1 / 5)
    
    func shrinkSizeWithInsetValue(float : CGFloat) {
        self.bounds = CGRectInset(self.bounds, insetValue, insetValue)
    }
    func expandSizeWithInsetValue(float: CGFloat) {
        self.bounds = CGRectInset(self.bounds, -insetValue, -insetValue)
    }
}