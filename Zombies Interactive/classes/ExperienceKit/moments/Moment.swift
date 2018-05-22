//
//  Moment.swift
//  Zombies Interactive
//
//  Created by Henry Spindell on 10/2/15.
//  Copyright © 2015 Scott Cambo. All rights reserved.
//

import Foundation

/// A component that makes up part of a MomentBlock; from an MomentBlock_Simple with the user to collect data,
/// to simple audio to advance the experience.
/// DO NOT instantiate this class, instead, use one of its subclasses.
class Moment: NSObject {
    
    /*
        How do we prevent this from being initialized?
    */
    
    /// The title of the moment; its role or purpose within the experience
    var title: String
    
    /// Whether or not this moment may be interrupted to dynamically insert 
    /// an MomentBlock_Simple from the OpportunityManager. Always defaults to false.
    var isInterruptable: Bool
    
    var canEvaluateOpportunity: Bool
    
    var duration: Float = 0
    var momentStarted = false
    var isPaused = true
    let eventManager = EventManager()
    override var description:String {
        return self.title
    }
    
    init(title: String, isInterruptable:Bool=true, canEvaluateOpportunity:Bool=false){
        // WARNING: DO NOT INIT A Moment(), USE ONLY SUBCLASSES - need to find solution
        // check the caller
        self.title = title
        self.isInterruptable = isInterruptable
        self.canEvaluateOpportunity = canEvaluateOpportunity
    }
    
    func start(){
        print("  \n(Moment::start)    Starting moment: \(self.title)")
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
        print("  (Moment::finished) Finished moment: \(self.title)")
        self.eventManager.trigger("nextMoment")
        // When finished, trigger action verifier?
        
    }
    
    /// Sets the moment to a state where it can be reused again to save memory
    // could be changed to prepare()
    // currently can't be used because the event listener sets multiple triggers
    // for the same object and it screws up everything
//    func reset() {
//    
//    }
}





