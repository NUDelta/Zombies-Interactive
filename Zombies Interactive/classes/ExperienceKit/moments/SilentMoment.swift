//
//  SilentMoment.swift
//  ExperienceTestSingle
//
//  Created by Hyung-Soon on 5/10/16.
//  Copyright © 2016 Hyung-Soon. All rights reserved.
//

import Foundation
class SilentMoment: Moment {
    var player:AVAudioPlayer?
    
    init(title:String?=nil) {
        super.init(title: title ?? "silent moment")
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
        super.start()
    }
    
    //note: there is nothing here that triggers finished()
    //hence the subclass will need to implement a way that triggers finished()
    //to signal that the moment has finished
    override func play() {
        super.play()
        self.player?.play()
    }
    
    override func pause(){
        super.pause()
        self.player?.pause()
    }
    
    override func finished() {
        self.player?.stop()
        super.finished()
    }

}
