//
//  Interim.swift
//  ZombieRunX
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
    
    var timer = NSTimer()
    var startTime: NSDate = NSDate()
    var timeRemaining: NSTimeInterval
    var player:AVAudioPlayer?
    var audioSession:AVAudioSession = AVAudioSession.sharedInstance()
    
    init(title:String?=nil, isInterruptable:Bool=false, lengthInSeconds:Float){
        self.lengthInSeconds = lengthInSeconds
        self.timeRemaining = NSTimeInterval(lengthInSeconds)
        super.init(title: title ?? "Interim (\(lengthInSeconds) seconds)", isInterruptable: isInterruptable)
        self.duration = self.lengthInSeconds
        
        let pathToAudio = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("silence", ofType: "mp3")!)
        
        do {
            self.player = try AVAudioPlayer(contentsOfURL: pathToAudio)
        } catch let error as NSError {
            print(error.localizedDescription)
            self.player = nil
        }
        
        self.player?.prepareToPlay()
    }

    
    override func start() {
        self.startTime = NSDate()
        self.eventManager.trigger("startingInterim")
        super.start()
    }
    
    override func play() {
        super.play()
        
        if timer.valid == false {
            print("  \(round(timeRemaining)) seconds remaining in interim")
            timer = NSTimer.scheduledTimerWithTimeInterval(timeRemaining, target: self, selector: Selector("finished"), userInfo: nil, repeats: false)
            self.startTime = NSDate()
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
    
    
}