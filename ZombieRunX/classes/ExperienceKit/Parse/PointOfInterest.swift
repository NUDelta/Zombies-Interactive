//
//  PointOfInterest.swift
//  ZombieRunX
//
//  Created by Henry Spindell on 10/16/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation
import Parse

class PointOfInterest : PFObject, PFSubclassing {
    
    @NSManaged var experience: Experience?
    @NSManaged var location: PFGeoPoint?
    @NSManaged var trigger: String?
    @NSManaged var label: String?
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "PointOfInterest"
    }
    
}