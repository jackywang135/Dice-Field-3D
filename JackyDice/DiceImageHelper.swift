//
//  DiceImageHelper.swift
//  JackyDice
//
//  Created by JackyWang on 11/26/14.
//  Copyright (c) 2014 JACKYWANG. All rights reserved.
//

import Foundation
import UIKit

class DiceImageHelper {

    var diceAnimateImage = [UIImage]()
    private var diceImage = [UIImage]()
    
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

    func getDiceImageForNumber(num : Int) -> UIImage {
        return diceImage[(num - 1)] as UIImage
    }
}