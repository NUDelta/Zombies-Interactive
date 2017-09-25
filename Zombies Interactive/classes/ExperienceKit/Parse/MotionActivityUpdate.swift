//
//  MotionActivityUpdate.swift
//  Zombies Interactive
//
//  Created by Henry Spindell on 2/5/16.
//  Copyright © 2016 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation
import Parse

class MotionActivityUpdate: PFObject, PFSubclassing {
    
    private static var __once: () = {
            MotionActivityUpdate.registerSubclass()
        }()
    
    @NSManaged var experience: Experience?
    @NSManaged var location: PFGeoPoint?
    @NSManaged var state: String?
    @NSManaged var confidence: NSNumber?
    
    override class func initialize() {
        struct Static {
            static var onceToken : Int = 0;
        }
        _ = MotionActivityUpdate.__once
    }
    
    static func parseClassName() -> String {
        return "MotionActivityUpdate"
    }
    
}
