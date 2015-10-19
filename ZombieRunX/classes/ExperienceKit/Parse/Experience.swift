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
    @NSManaged var title: String?
    @NSManaged var point: PFGeoPoint?
    @NSManaged var dateStarted: NSDate?
    @NSManaged var dateCompleted: NSDate?
    
    var completed: Bool {
        get { return self["completed"] as! Bool }
        set { self["completed"] = newValue }
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