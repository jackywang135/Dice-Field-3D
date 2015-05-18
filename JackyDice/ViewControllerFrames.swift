//
//  ViewControllerFrames.swift
//  JackyDice
//
//  Created by Jacky Wang on 5/19/15.
//  Copyright (c) 2015 JACKYWANG. All rights reserved.
//

import Foundation
import UIKit

//MARK: Global Variables
let screenWidth = UIScreen.mainScreen().bounds.width
let screenHeight = UIScreen.mainScreen().bounds.height

let bottomViewHeight = screenHeight/10
let bottomViewWidth = screenWidth

let bottomViewHiddenFrame = CGRectMake(0, screenHeight, bottomViewWidth, bottomViewHeight)
let bottomViewNormalFrame = CGRectMake(0, screenHeight - bottomViewHeight,bottomViewWidth, bottomViewHeight)
let bottomViewDuringAdFrame = CGRectMake(0, adShowingFrame.origin.y - bottomViewHeight, bottomViewWidth, bottomViewHeight)


var adHeight = UIDevice.currentDevice().userInterfaceIdiom == .Pad ? CGFloat(66) : CGFloat(50)

let adHiddenFrame = CGRectMake(0, screenHeight, screenWidth, adHeight)
let adShowingFrame = CGRectMake(0, screenHeight - adHeight, screenWidth, adHeight)

let animatorViewDuringAdFrame = CGRectMake(0, 0, screenWidth, screenHeight - bottomViewHeight - adHeight)
let animatorViewHideAdFrame = CGRectMake(0, 0, screenWidth, screenHeight - bottomViewHeight)
