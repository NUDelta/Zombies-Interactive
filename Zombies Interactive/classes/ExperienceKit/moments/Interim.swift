//
//  Interim.swift
//  Zombies Interactive
//
//  Created by Henry Spindell on 10/11/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation
import MediaPlayer

/// A moment that does not play audio related to the experience. It expires after a specified length.
/// The Interim class and all its subclasses play silent audio at all times in order to prevent the app from shutting down in the background.
class Interim: Moment{
    
    /// The length of the interim period
    var lengthInSeconds: Float
    
    var timer = Timer()
    var startTime: Date = Date()
    var timeRemaining: TimeInterval
    var player:AVAudioPlayer?
    
    init(title:String?=nil, isInterruptable:Bool=false, lengthInSeconds:Float, canEvaluateOpportunity:Bool=false){
        self.lengthInSeconds = lengthInSeconds
        self.timeRemaining = TimeInterval(lengthInSeconds)
        super.init(title: title ?? "Interim (\(lengthInSeconds) seconds)", isInterruptable: isInterruptable, canEvaluateOpportunity: canEvaluateOpportunity)
        self.duration = self.lengthInSeconds
        
        //note: silence is just a 15 minute file with no noise
        //(15 minutes is assumed to be a long enough period)
        let pathToAudio = URL(fileURLWithPath: Bundle.main.path(forResource: "silence", ofType: "mp3")!)
        
        do {
            self.player = try AVAudioPlayer(contentsOf: pathToAudio)
        } catch let error as NSError {
            print(error.localizedDescription)
            self.player = nil
        }
        
        self.player?.prepareToPlay()
    }

    
    override func start() {
        self.startTime = Date()
        super.start()
        print("(Interim::start) triggering startingInterim")
        self.eventManager.trigger("startingInterim", information: ["duration": "\(duration)"])
    }
    
    override func play() {
        super.play()
        
        if timer.isValid == false {
            print("  \(round(timeRemaining)) seconds remaining in interim")
            timer = Timer.scheduledTimer(timeInterval: timeRemaining, target: self, selector: #selector(Moment.finished), userInfo: nil, repeats: false)
            self.startTime = Date()
        }
        
        self.player?.play()
    }
    
    override func pause(){
        super.pause()
        self.player?.pause()
        
        timer.invalidate()
        self.timeRemaining = self.timeRemaining + startTime.timeIntervalSinceNow
    }
    
    override func finished() {
        timer.invalidate()
        self.player?.stop()
        
        super.finished()
    }
    
//    override func reset() {
//        super.reset()
//        timeRemaining = NSTimeInterval(lengthInSeconds)
//    }
    
    
}
