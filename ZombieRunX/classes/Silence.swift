//
//  Silence.swift
//  ZombieRunX
//
//  Created by Henry Spindell on 10/11/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation

class Silence: Moment, AVAudioPlayerDelegate{
    /*
    * placeholder for silence in a Stage
    * Runs an NSTimer object
    */
    
    var player:AVAudioPlayer?
    var lengthInSeconds: Float // seconds of silence
    var timer = NSTimer()
    
    init(lengthInSeconds:Float, interruptable:Bool=false, title:String?=nil){
        self.lengthInSeconds = lengthInSeconds
        super.init(interruptable:interruptable, title: title ?? "Silence (\(lengthInSeconds) seconds)")
        
        // temporary until we get playlist implemented, but could be combined still
        // silence audio should probably be handled by something else
        // ESPECIALLY because this should never be specific to zombie run
        let pathToAudio = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("zombie-horde-loop", ofType: "mp3")!)
        
        do {
            self.player = try AVAudioPlayer(contentsOfURL: pathToAudio)
        } catch let error as NSError {
            print(error.localizedDescription)
            self.player = nil
        }
        
        // loop zombie horde entire time
        let audioAsset = AVURLAsset(URL: pathToAudio)
        let audioDurationSeconds = Float(CMTimeGetSeconds(audioAsset.duration))
        self.player?.numberOfLoops = Int(lengthInSeconds / audioDurationSeconds)
        
        self.player?.delegate = self
        self.player?.prepareToPlay()
    }
    
    override func play(){
        super.play()
        self.player?.play()
        if timer.valid == false {
            timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(lengthInSeconds), target: self, selector: Selector("finished"), userInfo: nil, repeats: false)
        } else {
            timer.fire()
        }
    }
    
    override func pause(){
        super.pause()
        self.player?.pause()
        timer.invalidate()
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        if let error = error {
            print(error.localizedDescription)
        }
    }
}