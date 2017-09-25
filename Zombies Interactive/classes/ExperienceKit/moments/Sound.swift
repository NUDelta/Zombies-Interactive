//
//  Sound.swift
//  Zombies Interactive
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
    var numFilesPlayed:Int = 0
    
    init(fileNames: [String], isInterruptable:Bool=false, title:String?=nil, canEvaluateOpportunity:Bool=false){
        self.fileNames = fileNames
        //[ Sound title is basically set to all the file names ] 
        super.init(title: title ?? fileNames.joined(separator: ">"), isInterruptable: isInterruptable, canEvaluateOpportunity: canEvaluateOpportunity)
        self.duration = calculateAudioDuration()
        
        setupNextAudioFile()
    }
    
    func calculateAudioDuration() -> Float {
        var totalDuration:Float = 0
        print(fileNames)
        
        for path in fileNames {
            let asset = AVURLAsset(url: URL(fileURLWithPath: Bundle.main.path(forResource: path, ofType: "mp3")!), options: nil)
            //print("loading asset:\(asset)")
            let audioDuration = asset.duration
            totalDuration += Float(CMTimeGetSeconds(audioDuration))
        }
        return totalDuration
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        numFilesPlayed += 1
        if numFilesPlayed == fileNames.count {
            super.finished()
        } else {
            setupNextAudioFile()
            self.player?.play()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
    }
    
    func setupNextAudioFile() {
        let pathToAudio = URL(fileURLWithPath: Bundle.main.path(forResource: fileNames[numFilesPlayed], ofType: "mp3")!)
        
        do {
            self.player = try AVAudioPlayer(contentsOf: pathToAudio)
        } catch let error as NSError {
            print(error.localizedDescription)
            self.player = nil
        }
        
        // For audio backgrounding
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
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
