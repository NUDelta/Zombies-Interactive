//
//  Silence.swift
//  ZombieRunX
//
//  Created by Henry Spindell on 10/11/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation
import MediaPlayer

class Silence: Moment{
    
    var lengthInSeconds: Float // seconds of silence
    var timer = NSTimer()
    var startTime: NSDate = NSDate()
    var timeRemaining: NSTimeInterval
    var player:AVAudioPlayer?
    var audioSession:AVAudioSession = AVAudioSession.sharedInstance()
    
    init(lengthInSeconds:Float, interruptable:Bool=false, title:String?=nil){
        self.lengthInSeconds = lengthInSeconds
        self.timeRemaining = NSTimeInterval(lengthInSeconds)
        super.init(interruptable:interruptable, title: title ?? "Silence (\(lengthInSeconds) seconds)")
        
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
        self.eventManager.trigger("startingSilence")
        super.start()
    }
    
    override func play() {
        super.play()
        
        if timer.valid == false {
            print("  \(timeRemaining) seconds remaining in silence")
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