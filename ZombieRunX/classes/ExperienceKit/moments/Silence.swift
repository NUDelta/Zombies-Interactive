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
    
    init(lengthInSeconds:Float, interruptable:Bool=false, title:String?=nil){
        self.lengthInSeconds = lengthInSeconds
        super.init(interruptable:interruptable, title: title ?? "Silence (\(lengthInSeconds) seconds)")
    }

    
    override func start() {
        super.start()
        
        do {
            try AVAudioSession.sharedInstance().setActive(false, withOptions: .NotifyOthersOnDeactivation)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    override func play() {
        super.play()
        
        if timer.valid == false {
            timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(lengthInSeconds), target: self, selector: Selector("finished"), userInfo: nil, repeats: false)
        } else {
            timer.fire()
        }
    }
    
    override func pause(){
        super.pause()
        timer.invalidate()
    }
    
    override func finished() {
        super.finished()
        timer.invalidate()
    }
}