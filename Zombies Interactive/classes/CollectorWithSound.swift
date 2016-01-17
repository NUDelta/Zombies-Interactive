//
//  CollectorWithSound.swift
//  Zombies Interactive
//
//  Created by Henry Spindell on 1/16/16.
//  Copyright © 2016 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation

/// A moment that collects device data throughout its duration, and
/// does not try to make sense of it in real time. Saves an associated DataEvent in Parse.
/// Also plays audio, like the Sound class.
class CollectorWithSound : Sound {
    /// The types of data that should be collected for the duration (i.e. Location, Motion).
    var sensors: [Sensor]
    
    /// The thing you hope to find by recording data.
    var dataLabel: String
    
    var additionalTime: Double
    var timer = NSTimer()
    
    /**
     Initializes a new SensorCollector with the provided parameters
     - Parameters:
     - lengthInSeconds: The number of seconds to record data for
     - dataLabel: The thing you want to find by recording data
     - dataTypes: The types of data that should be collected for the duration (i.e. Location, Motion)
     */
    
    init(fileNames: [String], additionalTime: Double?=0, interruptable:Bool=false, title:String?=nil, dataLabel:String, sensors:[Sensor]){
        self.sensors = sensors
        self.dataLabel = dataLabel
        self.additionalTime = additionalTime ?? 0
        super.init(fileNames: fileNames, title: title ?? "Find \(dataLabel)", isInterruptable: interruptable)
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
