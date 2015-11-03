//
//  WaitForKnock.swift
//  ZombieRunX
//
//  Created by Henry Spindell on 10/15/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

//import Foundation
//import CoreMotion
//
//class WaitForDoubleKnock: Interim, TSTapDetectorDelegate{
//    
//    var tapDetector: TSTapDetector?
//    var dataLabel: String
//    
//    init(lengthInSeconds: Float, title:String?=nil, dataLabel:String){
//        self.dataLabel = dataLabel
//        super.init(lengthInSeconds: lengthInSeconds, title: title ?? "Record \(dataLabel)")
//    }
//    
//    override func start() {
//        print("  Starting to listen for knock")
//        self.tapDetector = TSTapDetector.init()
//        self.tapDetector?.listener.collectMotionInformationWithInterval(10)
//        self.tapDetector?.delegate = self
//        super.start()
//    }
//    
//    // Knock detection callback
//    func didDetectKnock(detector: TSTapDetector!) {
//        print("  detected double knock")
//        
//        self.eventManager.trigger("foundPointOfInterest", information: ["trigger": "double_knock", "label": self.dataLabel, "interaction": self.title])
//    }
//    
//    override func finished() {
//        super.finished()
//        self.tapDetector?.listener.stopCollectingMotionInformation()
//        self.tapDetector?.recognizer.stopRecorder()
//    }
//
//}