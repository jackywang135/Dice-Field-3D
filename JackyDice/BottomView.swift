//
//  BottomView.swift
//  JackyDice
//
//  Created by Jacky Wang on 11/21/14.
//  Copyright (c) 2014 JACKYWANG. All rights reserved.
//

import Foundation
import UIKit

protocol BottomViewDelegate {
    func pressedButtonShake(bottomView : BottomView)
    func pressedButtonAddDice(bottomView : BottomView)
}

class BottomView : UIView {
    
    var buttonShake : UIButton!
    var buttonAddDice : UIButton!
    var labelTotal : UILabel!
    var delegate : BottomViewDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpBackgroundImage()
        setUpButtonAddDice()
        setUpButtonShake()
        setUpTotalLabel()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    let font = UIFont(name: "HelveticaNeue", size: 40)
    let color = UIColor.whiteColor()
    
    func setUpTotalLabel() {
        labelTotal = UILabel(frame: CGRectMake(0, 0, bounds.width / 3, bounds.height))
        labelTotal.adjustsFontSizeToFitWidth = true
        labelTotal.font = font
        labelTotal.textColor = color
        labelTotal.textAlignment = NSTextAlignment.Center
        addSubview(labelTotal)
    }
    
    func setUpBackgroundImage() {
        backgroundColor = UIColor(patternImage: UIImage(named: "wood")!)
    }
    
    func setUpButtonShake() {
        buttonShake = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        buttonShake.frame = CGRectMake(bounds.width / 3, 0, bounds.width / 3, bounds.height)
        buttonShake.setTitle("Shake", forState: UIControlState.Normal)
        buttonShake.titleLabel!.adjustsFontSizeToFitWidth = true
        buttonShake.titleLabel!.font = font
        buttonShake.addTarget(self, action:"shake:", forControlEvents: UIControlEvents.TouchUpInside)
        
//        buttonShake.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).CGColor
//        buttonShake.layer.borderWidth = 5
//        buttonShake.layer.cornerRadius = 0
        
        //buttonShake.backgroundColor = UIColor(patternImage: UIImage(named: "wood")!)
        
        buttonShake.layer.shadowColor = UIColor.blackColor().CGColor
        buttonShake.layer.shadowOffset = CGSizeMake(0, -3)
        buttonShake.layer.shadowRadius = 5
        addSubview(buttonShake)
    }
    
    func setUpButtonAddDice() {
        buttonAddDice = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        buttonAddDice.frame = CGRectMake(bounds.width * 2 / 3, 0 , bounds.width / 3, bounds.height)
        buttonAddDice.setTitle("+", forState: UIControlState.Normal)
        buttonAddDice.titleLabel!.adjustsFontSizeToFitWidth = true
        buttonAddDice.titleLabel!.font = font
        buttonAddDice.addTarget(self, action:"add:", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(buttonAddDice)
    }
    
    func shake(sender:UIButton) {
        delegate.pressedButtonShake(self)
    }
    
    func add(sender:UIButton) {
        delegate.pressedButtonAddDice(self)
    }
}