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
    
    private static var __once: () = {
            WorldObject.registerSubclass()
        }()
    
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
            static var onceToken : Int = 0;
        }
        _ = WorldObject.__once
    }
    
    static func parseClassName() -> String {
        return "WorldObject"
    }
    
}
