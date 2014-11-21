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
            self.displayAndSetNumber(self.getRandomDiceNumber())})
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
        animationImages = diceAnimateImage
        animationDuration = 0.5
        animationRepeatCount = 1
        startAnimating()
    }
}