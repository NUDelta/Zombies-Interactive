//
//  WorldObject.swift
//  Zombies Interactive
//
//  Created by Henry Spindell on 10/16/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation
import Parse

class WorldObject : PFObject, PFSubclassing {
    
    @NSManaged var interaction: String?
    @NSManaged var experience: Experience?
    @NSManaged var location: PFGeoPoint?
    @NSManaged var trigger: String?
    @NSManaged var label: String?
    @NSManaged var MomentBlockSimple: String?
    @NSManaged var verifiedTimes: NSNumber?
    @NSManaged var validatedTimes: NSNumber?
    @NSManaged var invalidatedTimes: NSNumber?
    @NSManaged var variation: NSNumber?
    
    var verified: Bool {
        get { return self["verified"] as! Bool }
        set { self["verified"] = newValue }
    }
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "WorldObject"
    }
    
}