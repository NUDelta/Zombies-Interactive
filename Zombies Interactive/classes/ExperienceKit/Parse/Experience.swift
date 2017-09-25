//
//  Experience.swift
//  Zombies Interactive
//
//  Created by Henry Spindell on 10/5/15.
//  Copyright © 2015 Scott Cambo. All rights reserved.
//

import Foundation
import Parse

// Experience: a log of a user's in-app experience
class Experience : PFObject, PFSubclassing {
    
    private static var __once: () = {
            Experience.registerSubclass()
        }()
    
    @NSManaged var user: PFUser?
    @NSManaged var title: String?
    @NSManaged var point: PFGeoPoint?
    @NSManaged var dateStarted: Date?
    @NSManaged var dateCompleted: Date?
    
    var completed: Bool {
        get { return self["completed"] as! Bool }
        set { self["completed"] = newValue }
    }
    
    override class func initialize() {
        struct Static {
            static var onceToken : Int = 0;
        }
        _ = Experience.__once
    }
    
    static func parseClassName() -> String {
        return "Experience"
    }
    
}
