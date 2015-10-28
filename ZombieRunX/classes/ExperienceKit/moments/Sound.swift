//
//  Sound.swift
//  ZombieRunX
//
//  Created by Henry Spindell on 10/11/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation
import MediaPlayer

class Sound: Moment, AVAudioPlayerDelegate{
    
    var fileName:String
    var player:AVAudioPlayer?
    var audioSession:AVAudioSession = AVAudioSession.sharedInstance()
    
    init(fileName: String, interruptable:Bool=false, title:String?=nil){
        self.fileName = fileName
        
        let pathToAudio = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(fileName, ofType: "mp3")!)
        
        do {
            self.player = try AVAudioPlayer(contentsOfURL: pathToAudio)
        } catch let error as NSError {
            print(error.localizedDescription)
            self.player = nil
        }
        super.init(interruptable:interruptable, title: title ?? fileName)
        
        self.player?.delegate = self
        self.player?.prepareToPlay()
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        super.finished()
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        if let error = error {
            print(error.localizedDescription)
        }
    }
    
    
    override func start() {
        self.eventManager.trigger("startingSound")
        super.start()
    }
    
    override func play(){
        super.play()
        self.player?.play()
    }
    
    override func pause(){
        super.pause()
        self.player?.pause()
    }
    
    override func finished() {
        self.player?.stop()
        self.player?.prepareToPlay()
        
        super.finished()
    }
    
}