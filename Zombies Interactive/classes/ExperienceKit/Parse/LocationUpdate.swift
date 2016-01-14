//
//  LocationUpdate.swift
//  Zombies Interactive
//
//  Created by Henry Spindell on 10/5/15.
//  Copyright © 2015 Scott Cambo. All rights reserved.
//

import Foundation
import Parse

class LocationUpdate : PFObject, PFSubclassing {
    
    @NSManaged var experience: Experience?
    @NSManaged var location: PFGeoPoint?
    @NSManaged var altitude: NSNumber?
    @NSManaged var speed: NSNumber?
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "LocationUpdate"
    }
    
}