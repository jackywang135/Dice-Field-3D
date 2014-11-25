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
        setUpButtonAddDice()
        setUpButtonShake()
        setUpTotalLabel()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setUpTotalLabel() {
        labelTotal = UILabel(frame: CGRectMake(0, 0, bounds.width / 3, bounds.height))
        addSubview(labelTotal)
    }
    
    func setUpButtonShake() {
        buttonShake = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        buttonShake.frame = CGRectMake(bounds.width / 3, 0, bounds.width / 3, bounds.height)
        buttonShake.setTitle("Shake", forState: UIControlState.Normal)
        buttonShake.addTarget(self, action:"shake:", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(buttonShake)
    }
    
    func setUpButtonAddDice() {
        buttonAddDice = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        buttonAddDice.frame = CGRectMake(bounds.width * 2 / 3, 0 , bounds.width / 3, bounds.height)
        buttonAddDice.setTitle("Add", forState: UIControlState.Normal)
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