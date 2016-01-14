//
//  Listener.swift
//  Zombies Interactive
//
//  Created by Henry Spindell on 11/2/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation

/// An enum that represents different gestures or actions that the user can take.
enum Trigger: String {
    case Knock = "knock",
    DoubleKnock = "double_knock",
    Speech = "speech"
}

/// A moment that listens for specified triggers (see Trigger) to imply some data point's existence.
/// DO NOT instantiate this class, instead, use one of its subclasses.
class TriggerListener: Interim {
    
    /*
        How do we prevent this from being initialized?
    */
    
    /// The thing whose presence/location is suggested upon trigger
    var dataLabel: String
    
    /// The action or gesture
    var trigger: Trigger
    
    /// Specifies whether or not the listener should listen for multiple triggers (true), or finish upon the first (false)
    var recordMultiple: Bool
    
    init(title:String?=nil, isInterruptable:Bool=false, lengthInSeconds: Float, dataLabel:String, trigger: Trigger, recordMultiple:Bool=false){
        self.dataLabel = dataLabel
        self.trigger = trigger
        self.recordMultiple = recordMultiple
        super.init(title: title ?? "Listen for \(trigger.rawValue)", isInterruptable: isInterruptable, lengthInSeconds: lengthInSeconds)
    }
    
    override func start() {
        print("  Starting to listen for \(trigger)")
        super.start()
    }
    

    func didReceiveTrigger() {
        print("  received \(trigger) trigger")
        self.eventManager.trigger("foundPointOfInterest", information: ["trigger": trigger.rawValue, "label": dataLabel, "interaction": title])
        if recordMultiple == false {
            self.finished()
        }
    }
}