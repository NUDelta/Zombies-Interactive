//
//  SensorCollector.swift
//  Zombies Interactive
//
//  Created by Henry Spindell on 10/11/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation


/// A moment that collects device data throughout its duration, and 
/// does not try to make sense of it in real time. Saves an associated sensorMoment in Parse.
class SensorCollector: Interim {
    /// The types of data that should be collected for the duration (i.e. Location, Motion).
    var sensors: [Sensor]
    
    /// The thing you hope to find by recording data.
    var dataLabel: String
    
    /**
     Initializes a new SensorCollector with the provided parameters
     - Parameters:
     - lengthInSeconds: The number of seconds to record data for
     - dataLabel: The thing you want to find by recording data
     - dataTypes: The types of data that should be collected for the duration (i.e. Location, Motion)
     */
    init(lengthInSeconds: Float, interruptable:Bool=false, title:String?=nil, dataLabel:String, sensors:[Sensor]){
        self.sensors = sensors
        self.dataLabel = dataLabel
        
        super.init(title: title ?? "Find \(dataLabel)", lengthInSeconds: lengthInSeconds)
    }
}
