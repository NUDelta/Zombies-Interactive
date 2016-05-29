//
//  Requirement.swift
//  Zombies Interactive
//
//  Created by Henry Spindell on 12/8/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation
import CoreLocation

//poll
//info: get within radius of X
//returns: objects
//execute this moment if
//the object I define == one of the objects returned from query

enum Condition {
    case MinSpeed, MaxSpeed, TimeElapsed, TimeRemaining, InRegion, ExistsObject
    // time elapsed and remaining refer to experience time, not real time (which would include pauses, etc.)
}

class Requirement : NSObject {
    var canInsertImmediately: Bool? = false
    var conditions: [Condition]
    var speed: CLLocationSpeed?
    var seconds: NSTimeInterval?
    var region: CLCircularRegion?
    var withinRadius: Double?
    var objectLabel: String?
    var variationNumber: NSNumber?
    
    init(conditions:[Condition], speed:CLLocationSpeed?=nil, seconds:NSTimeInterval?=nil, region:CLCircularRegion?=nil, canInsertImmediately:Bool?=false, withinRadius:Double?=0, objectLabel:String?="", variationNumber:NSNumber?=nil) {
        self.conditions = conditions
        self.speed = speed
        self.seconds = seconds
        self.region = region
        self.withinRadius = withinRadius
        self.objectLabel = objectLabel
        self.variationNumber = variationNumber
        
        self.canInsertImmediately = canInsertImmediately
    }
    
    // TODO ensure every condition has a matching value, otherwise crash
    
    
}