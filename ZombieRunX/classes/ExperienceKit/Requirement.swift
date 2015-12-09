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
    case MinSpeed, MaxSpeed, TimeRemaining, TimeElapsed, InRegion
}

class Requirement : NSObject {
    var conditions: [Condition]
    var speed: CLLocationSpeed?
    var time: NSTimeInterval?
    var region: CLCircularRegion?
    
    init(conditions:[Condition], speed:CLLocationSpeed?=nil, time:NSTimeInterval?=nil, region:CLCircularRegion?=nil) {
        self.conditions = conditions
        self.speed = speed
        self.time = time
        self.region = region
    }
    
    // TODO ensure every condition has a matching value, otherwise crash
    
    
}