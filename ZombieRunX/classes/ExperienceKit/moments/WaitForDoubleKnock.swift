//
//  WaitForKnock.swift
//  ZombieRunX
//
//  Created by Henry Spindell on 10/15/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation
import CoreMotion

class WaitForDoubleKnock: Silence, TSTapDetectorDelegate{
    
    var tapDetector: TSTapDetector?
    var dataLabel: String
    
    init(lengthInSeconds: Float, interruptable:Bool=false, title:String?=nil, dataLabel:String){
        self.dataLabel = dataLabel
        super.init(lengthInSeconds: lengthInSeconds, interruptable:interruptable, title: title ?? "Record \(dataLabel)")
    }
    
    override func start() {
        super.start()
        print("  Starting to listen for knock")
        self.tapDetector = TSTapDetector.init()
        self.tapDetector?.listener.collectMotionInformationWithInterval(10)
        self.tapDetector?.delegate = self
    }
    
    // Knock detection callback
    func didDetectKnock(detector: TSTapDetector!) {
        print("  detected double knock")
        
        self.eventManager.trigger("foundPointOfInterest", information: ["trigger": "doubleKnock", "label": self.dataLabel])
    }
    
    override func finished() {
        super.finished()
        self.tapDetector?.listener.stopCollectingMotionInformation()
        self.tapDetector?.recognizer.stopRecorder()
    }

}