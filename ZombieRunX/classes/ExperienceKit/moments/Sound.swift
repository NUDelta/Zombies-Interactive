//
//  Sound.swift
//  ZombieRunX
//
//  Created by Henry Spindell on 10/11/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation
import MediaPlayer

/// A moment that just plays a one or more specified audio files and then finishes.
class Sound: Moment, AVAudioPlayerDelegate{
    
    /// names of mp3 files, without extensions, that will be played in order
    var fileNames:[String]
    
    var player:AVAudioPlayer?
    var audioSession:AVAudioSession = AVAudioSession.sharedInstance()
    var numFilesPlayed:Int = 0
    
    init(fileNames: [String], interruptable:Bool=false, title:String?=nil){
        self.fileNames = fileNames
        super.init(title: title ?? fileNames.joinWithSeparator(">"))
        self.duration = calculateAudioDuration()
        
        setupNextAudioFile()
    }
    
    func calculateAudioDuration() -> Float {
        var totalDuration:Float = 0
        
        for path in fileNames {
            let asset = AVURLAsset(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(path, ofType: "mp3")!), options: nil)
            let audioDuration = asset.duration
            totalDuration += Float(CMTimeGetSeconds(audioDuration))
        }
        return totalDuration
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        numFilesPlayed += 1
        if numFilesPlayed == fileNames.count {
            super.finished()
        } else {
            setupNextAudioFile()
            self.player?.play()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        if let error = error {
            print(error.localizedDescription)
        }
    }
    
    func setupNextAudioFile() {
        let pathToAudio = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(fileNames[numFilesPlayed], ofType: "mp3")!)
        
        do {
            self.player = try AVAudioPlayer(contentsOfURL: pathToAudio)
        } catch let error as NSError {
            print(error.localizedDescription)
            self.player = nil
        }
        
        self.player?.delegate = self
        self.player?.prepareToPlay()
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
        // TODO clean up for reuse
        self.player?.stop()
        self.player?.prepareToPlay()
        
        super.finished()
    }
    
}