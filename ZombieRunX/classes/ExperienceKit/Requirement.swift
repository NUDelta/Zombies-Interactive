//
//  Requirement.swift
//  ZombieRunX
//
//  Created by Henry Spindell on 12/8/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation
import CoreLocation

enum Condition {
    case MinSpeed, MaxSpeed, TimeRemaining, TimeElapsed
}

class Requirement : NSObject {
    var conditions: [Condition]
    var speed: CLLocationSpeed?
    var time: NSTimeInterval?
    
    init(conditions:[Condition], speed:CLLocationSpeed?=nil, time:NSTimeInterval?=nil) {
        self.conditions = conditions
        self.speed = speed
        self.time = time
    }
    
    // TODO ensure every condition has a matching value, otherwise crash
    
    
}