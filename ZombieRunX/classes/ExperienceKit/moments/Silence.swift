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
    
    var player:MPMusicPlayerController?
    var lengthInSeconds: Float // seconds of silence
    var timer = NSTimer()
    
    init(lengthInSeconds:Float, interruptable:Bool=false, title:String?=nil){
        self.lengthInSeconds = lengthInSeconds
        super.init(interruptable:interruptable, title: title ?? "Silence (\(lengthInSeconds) seconds)")
        
        // TODO let view controller handle this somehow?
        // playing music from library is too specific to ZR to be here, probably
        //  add some effect to make it more immersive?
        // & only play music if the silence is at least 30 seconds
        // maybe a ZR class should subclass an ExperienceKit class and add this
        
        //with MPMediaPlayer
//        self.player = MPMusicPlayerController.systemMusicPlayer()
//        self.player?.setQueueWithQuery(MPMediaQuery.songsQuery())
//        self.player?.shuffleMode = MPMusicShuffleMode.Songs
//        self.player?.beginGeneratingPlaybackNotifications()


//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playbackChanged",
//            name:MPMusicPlayerControllerPlaybackStateDidChangeNotification,
//            object: MPMusicPlayerController.systemMusicPlayer())
    }
    
    func playbackChanged(){
        print("playback changed")
    }
    
    override func play(){
        super.play()
        
        if let p = self.player{
            p.play()
            print("  playing song " + (p.nowPlayingItem != nil ? p.nowPlayingItem!.title! : ""))
            print(p.playbackState.hashValue)
        }
        
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
    
    override func finished() {
        super.finished()
        self.player?.endGeneratingPlaybackNotifications()
        self.player?.stop()
        timer.invalidate()
    }
}