//
//  Moment.swift
//  ZombieRunX
//
//  Created by Henry Spindell on 10/2/15.
//  Copyright © 2015 Scott Cambo. All rights reserved.
//

import Foundation

/// A component that makes up part of a Stage; from an interaction with the user to collect data,
/// to simple audio to advance the experience.
/// DO NOT instantiate this class, instead, use one of its subclasses.
class Moment: NSObject {
    
    /*
        How do we prevent this from being initialized?
    */
    
    /// The title of the moment; its role or purpose within the experience
    var title: String
    
    var duration: Float = 0
    var momentStarted = false
    var isPaused = true
    let eventManager = EventManager()
    override var description:String {
        return self.title
    }
    
    init(title: String){
        // WARNING: DO NOT INIT A Moment(), USE ONLY SUBCLASSES - need to find solution
        // check the caller
        self.title = title
    }
    
    func start(){
        print("  Starting moment: \(self.title)")
        momentStarted = true
        // passed as string so it will conform to AnyObject
        eventManager.trigger("startingMoment", information: ["duration": "\(duration)"])
        self.play()
    }

    func play(){
        self.isPaused = false
    }

    func pause(){
        self.isPaused = true
    }
    
    func finished(){
        print("  Finished moment: \(self.title)")
        
        self.eventManager.trigger("nextMoment")
    }
}





