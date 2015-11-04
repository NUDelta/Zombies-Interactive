//
//  SensorMoment.swift
//  ZombieRunX
//
//  Created by Henry Spindell on 11/3/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation
import Parse

/// An index for a dataset from a SensorCollector moment.
class SensorMoment : PFObject, PFSubclassing {
    
    @NSManaged var experience: Experience?
    @NSManaged var startDate: NSDate?
    @NSManaged var endDate: NSDate?
    @NSManaged var sensors: [String]?
    @NSManaged var label: String?
    @NSManaged var interaction: String?
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "SensorMoment"
    }
    
}