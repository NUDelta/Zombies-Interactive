//
//  DataMoment.swift
//  ZombieRunX
//
//  Created by Henry Spindell on 10/11/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation



/// A moment that collects device data throughout its duration. Saves an associated DataEvent in Parse.
class DataMoment: Silence {
    /// The types of data that should be collected for the duration (i.e. Location, Motion)
    var dataTypes: [DataCollectionType]
    
    /// The thing you hope to find by recording data
    var dataLabel: String
    
    /**
     Initializes a new DataMoment with the provided parameters
     - Parameters:
     - lengthInSeconds: The number of seconds to record data for
     - dataLabel: The thing you want to find by recording data
     - dataTypes: The types of data that should be collected for the duration (i.e. Location, Motion)
     */
    init(lengthInSeconds: Float, interruptable:Bool=false, title:String?=nil, dataLabel:String, dataTypes:[DataCollectionType]){
        self.dataTypes = dataTypes
        self.dataLabel = dataLabel
        
        super.init(lengthInSeconds: lengthInSeconds, interruptable: interruptable, title: title ?? "Find \(dataLabel)")
    }
}
