//
//  DataEvent.swift
//  ZombieRunX
//
//  Created by Henry Spindell on 10/5/15.
//  Copyright © 2015 Scott Cambo. All rights reserved.
//

import Foundation
import Parse

// DataEvent: an index for a dataset from an experience
class DataEvent : PFObject, PFSubclassing {
    
    @NSManaged var experience: Experience?
    @NSManaged var startDate: NSDate?
    @NSManaged var endDate: NSDate?
    @NSManaged var dataTypes: [String]?
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
        return "DataEvent"
    }
    
}