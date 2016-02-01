//
//  TriggerListenerWithSound.swift
//  Zombies Interactive
//
//  Created by Henry Spindell on 1/16/16.
//  Copyright © 2016 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation


/// A moment that listens for specified triggers (see Trigger) to imply some data point's existence.
/// DO NOT instantiate this class, instead, use one of its subclasses.
class TriggerListenerWithSound : Sound {

    
    /// The thing whose presence/location is suggested upon trigger
    var dataLabel: String
    
    /// The action or gesture
    var trigger: Trigger
    
    /// Specifies whether or not the listener should listen for multiple triggers (true), or finish upon the first (false)
    var recordMultiple: Bool
    
    var additionalTime: Double
    var timer = NSTimer()
    
    init(title:String?=nil, isInterruptable:Bool=false, fileNames:[String], dataLabel:String, trigger: Trigger, recordMultiple:Bool=false, additionalTime:Double?=0){
        self.dataLabel = dataLabel
        self.trigger = trigger
        self.recordMultiple = recordMultiple
        self.additionalTime = additionalTime ?? 0
        
        super.init(fileNames: fileNames, title: title ?? "Listen for \(trigger.rawValue)", isInterruptable: isInterruptable)
    }
    
    override func start() {
        print("  Starting to listen for \(trigger)")
        super.start()
    }
    
    
    func didReceiveTrigger() {
        print("  received \(trigger) trigger")
        self.eventManager.trigger("foundWorldObject", information: ["trigger": trigger.rawValue, "label": dataLabel, "interaction": title])
        if recordMultiple == false {
            self.finished()
        }
    }
    
    
    override func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        numFilesPlayed += 1
        if numFilesPlayed == fileNames.count {
            
            if additionalTime > 0 {
                timer = NSTimer.scheduledTimerWithTimeInterval(additionalTime, target: self, selector: Selector("finished"), userInfo: nil, repeats: false)
                
            } else {
                super.finished()
            }
            
        } else {
            setupNextAudioFile()
            self.player?.play()
        }
    }
    
}