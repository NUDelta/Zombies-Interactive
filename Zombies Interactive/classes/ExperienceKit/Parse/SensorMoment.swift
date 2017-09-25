//
//  SensorMoment.swift
//  Zombies Interactive
//
//  Created by Henry Spindell on 11/3/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation
import Parse

/// An index for a dataset from a SensorCollector moment.
class SensorMoment : PFObject, PFSubclassing {
    
    private static var __once: () = {
            SensorMoment.registerSubclass()
        }()
    
    @NSManaged var experience: Experience?
    @NSManaged var startDate: Date?
    @NSManaged var endDate: Date?
    @NSManaged var sensors: [String]?
    @NSManaged var label: String?
    @NSManaged var MomentBlockSimple: String?
    
    override class func initialize() {
        struct Static {
            static var onceToken : Int = 0;
        }
        _ = SensorMoment.__once
    }
    
    static func parseClassName() -> String {
        return "SensorMoment"
    }
    
}
