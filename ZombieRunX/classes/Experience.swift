//
//  Experience.swift
//  ZombieRunX
//
//  Created by Henry Spindell on 10/5/15.
//  Copyright © 2015 Scott Cambo. All rights reserved.
//

import Foundation
import Parse

// Experience: a log of a user's in-app experience
class Experience : PFObject, PFSubclassing {
    
    @NSManaged var user: PFUser?
    @NSManaged var title: String? // changed missionName to title to make it general
    @NSManaged var point: PFGeoPoint?
    @NSManaged var dateFinished: NSDate?
    
    var finished: Bool {
        get { return self["finished"] as! Bool }
        set { self["finished"] = newValue }
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
        return "Experience"
    }
    
}