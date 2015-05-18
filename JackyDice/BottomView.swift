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
    
    private let font = UIFont(name: "HelveticaNeue", size: 40)
    private let color = UIColor.whiteColor()
    
    final private func setUpTotalLabel() {
        labelTotal = UILabel(frame: CGRectMake(0, 0, bounds.width / 3, bounds.height))
        labelTotal.adjustsFontSizeToFitWidth = true
        labelTotal.font = font
        labelTotal.textColor = color
        labelTotal.textAlignment = NSTextAlignment.Center
        addSubview(labelTotal)
    }
    
    final private func setUpBackgroundImage() {
        backgroundColor = UIColor(patternImage: UIImage(named: "wood")!)
    }
    
    final private func setUpButtonShake() {
        buttonShake = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        buttonShake.frame = CGRectMake(bounds.width / 3, 0, bounds.width / 3, bounds.height)
        buttonShake.setTitle("Shake", forState: UIControlState.Normal)
        buttonShake.setTitle("Rolling", forState: UIControlState.Disabled)
        buttonShake.setTitleColor(UIColor.blackColor(), forState: UIControlState.Disabled)
        buttonShake.titleLabel!.adjustsFontSizeToFitWidth = true
        buttonShake.titleLabel!.font = font
        buttonShake.titleLabel!.textAlignment = NSTextAlignment.Center
        buttonShake.addTarget(self, action:"shake:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonShake.layer.borderColor = UIColor(white: 1, alpha: 0.5).CGColor
        buttonShake.layer.borderWidth = screenWidth/300
        buttonShake.layer.cornerRadius = screenWidth/25
        addSubview(buttonShake)
    }
    
    final private func setUpButtonAddDice() {
        buttonAddDice = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        buttonAddDice.frame = CGRectMake(bounds.width * 2 / 3, 0 , bounds.width / 3, bounds.height)
        buttonAddDice.setTitle("+", forState: UIControlState.Normal)
        buttonAddDice.setTitle("Full", forState: UIControlState.Disabled)
        buttonAddDice.titleLabel!.adjustsFontSizeToFitWidth = true
        buttonAddDice.titleLabel!.font = font
        buttonAddDice.titleLabel!.textAlignment = NSTextAlignment.Center
        buttonAddDice.addTarget(self, action:"add:", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(buttonAddDice)
    }
    
    final func shake(sender:UIButton) {
        delegate.pressedButtonShake(self)
        //animateViewPop(buttonShake)
    }
    
    final func add(sender:UIButton) {
        delegate.pressedButtonAddDice(self)
        //animateViewPop(buttonAddDice)
    }
}