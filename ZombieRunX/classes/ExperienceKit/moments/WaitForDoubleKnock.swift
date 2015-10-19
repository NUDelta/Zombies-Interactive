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
    
    override init(lengthInSeconds: Float, interruptable:Bool=false, title:String?=nil){
        super.init(lengthInSeconds: lengthInSeconds, interruptable:interruptable, title: title ?? "Wait For Knock")
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
        
        self.eventManager.trigger("foundPointOfInterest", information: ["trigger": "doubleKnock", "label": "tree"])
        
//        let pathToAudio = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("proximity-pip", ofType: "wav")!)
//        do {
//            self.player = try AVAudioPlayer(contentsOfURL: pathToAudio)
//        } catch let error as NSError {
//            print(error.localizedDescription)
//            self.player = nil
//        }
        
        self.player?.prepareToPlay()
        self.player?.play()
        self.finished()
    }
    
    override func finished() {
        super.finished()
        self.tapDetector?.listener.stopCollectingMotionInformation()
        self.tapDetector?.recognizer.stopRecorder()
    }

}