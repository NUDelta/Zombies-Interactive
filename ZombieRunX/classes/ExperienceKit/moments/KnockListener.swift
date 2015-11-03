//
//  KnockListener.swift
//  ZombieRunX
//
//  Created by Henry Spindell on 11/2/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation
import CoreMotion

class KnockListener: Listener, TSTapDetectorDelegate{
    
    var tapDetector: TSTapDetector?
    var requireDoubleKnock: Bool

    init(title:String?=nil, lengthInSeconds: Float, dataLabel:String, recordMultiple:Bool=false, requireDoubleKnock:Bool=false){
        self.requireDoubleKnock = requireDoubleKnock
        let trigger: Trigger = self.requireDoubleKnock ? .DoubleKnock : .Knock
        super.init(title: title, lengthInSeconds: lengthInSeconds, dataLabel: dataLabel,
            trigger: trigger, recordMultiple: recordMultiple)
    }
    
    override func start() {
        self.tapDetector = TSTapDetector.init()
        self.tapDetector?.listener.collectMotionInformationWithInterval(10)
        self.tapDetector?.delegate = self
        super.start()
    }
    
    // delegate method for tapDetector
    func didDetectKnock(detector: TSTapDetector!, isDouble: Bool) {
        print("  got knock, isDouble:\(isDouble)")
        
        if requireDoubleKnock == false {
            print("  detected knock")
            self.didReceiveTrigger()
            return
        }
        
        if isDouble {
            print("  detected double knock")
            self.didReceiveTrigger()
        }
    }
    
    
    override func finished() {
        self.tapDetector?.listener.stopCollectingMotionInformation()
        self.tapDetector?.recognizer.stopRecorder() // unnecessary?
        super.finished()
    }
    
}