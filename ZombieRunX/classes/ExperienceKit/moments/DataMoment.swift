//
//  DataMoment.swift
//  ZombieRunX
//
//  Created by Henry Spindell on 10/11/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation

class DataMoment: Sound {
    var dataTypes: [DataCollectionType]
    
    init(fileName:String, dataTypes:[DataCollectionType], interruptable:Bool=false, title:String?=nil){
        self.dataTypes = dataTypes
        super.init(fileName: fileName, interruptable: interruptable, title: title ?? fileName)
    }
}