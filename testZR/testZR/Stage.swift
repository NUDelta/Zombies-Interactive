//
//  Stage.swift
//  testZR
//
//  Created by Scott Cambo on 8/19/15.
//  Copyright (c) 2015 Scott Cambo. All rights reserved.
//

import Foundation
import AVFoundation
class AppStage: NSObject, AVAudioPlayerDelegate{
    var isPlaying = false
    var sounds:[String];
    var audioSession:AVAudioSession!
    var queue:AVQueuePlayer!
    let events = EventManager()
    init(sounds: [String]) {
        
        //set up sound queue for this stage
        queue = AVQueuePlayer() // AVQueuePlayer should go into the stage object
        audioSession = AVAudioSession();
        audioSession.setCategory(AVAudioSessionCategoryPlayback, error: nil);
        audioSession.setActive(true, error: nil);
        self.sounds = sounds;
        for fileName in sounds{
            let fileURL:NSURL = NSBundle.mainBundle().URLForResource(fileName, withExtension: ".wav")!
            var error: NSError?
            var avPlayer = AVPlayerItem(URL: fileURL)
            if avPlayer == nil {
                if let e = error {
                    println(e.localizedDescription)
                }
            }
            
            queue.insertItem(avPlayer, afterItem: nil)
            queue.seekToTime(CMTimeMake(0,1))
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "finished", name: "notificationKey", object:avPlayerEnd)
        //done setting up sound queue for this stage
        
        
    }
    
    func play(){
        self.queue.play()
    }
    
    func pause(){
        self.queue.pause()
    }
    

    func finished(){
        self.events.trigger("finished");
    }

    
}