//
//  DataMoment.swift
//  ZombieRunX
//
//  Created by Henry Spindell on 10/11/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation

class DataMoment: Silence {
    var dataTypes: [DataCollectionType]
    var dataLabel: String
    
    init(lengthInSeconds: Float, interruptable:Bool=false, title:String?=nil, dataLabel:String, dataTypes:[DataCollectionType]){
        self.dataTypes = dataTypes
        self.dataLabel = dataLabel
        super.init(lengthInSeconds: lengthInSeconds, interruptable: interruptable, title: title ?? "Find \(dataLabel)")
    }
}