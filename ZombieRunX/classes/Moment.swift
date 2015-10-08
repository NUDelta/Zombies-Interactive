//
//  Moment.swift
//  ZombieRunX
//
//  Created by Henry Spindell on 10/2/15.
//  Copyright © 2015 Scott Cambo. All rights reserved.
//

import Foundation

import AVFoundation
import AudioToolbox


class Moment: NSObject{
    var interruptable: Bool
    var isPaused = true
    var title: String
    let eventManager = EventManager()
    
    init(interruptable:Bool=false, title: String){
        self.interruptable = interruptable
        self.title = title
    }
    

    func play(){
        finished()
    }

    func pause(){
        self.isPaused = true
    }
    
    func finished(){
        print("  Finished moment: \(self.title)")
        
        self.eventManager.trigger("nextSound")
    }

    func restart(){
        
    }
    
    /* add a toString method, not sure of how to do this,
    but the method should return some info about the moment
    that would be useful for data analysis.
    */
}

class Sound: Moment, AVAudioPlayerDelegate{
    /* Implement this as an AudioPlayer */
    var fileName:String
    //var playerItem:AVPlayerItem
    var player:AVAudioPlayer?
    
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
    
    override func play(){
        self.player?.play()
        isPaused = false
    }
    
    override func pause(){
        self.player?.pause()
        isPaused = true
    }
    
}

class Silence: Moment{
    /* 
    * placeholder for silence in a Stage
    * Runs an NSTimer object
    */
    var lengthInSeconds: Float // seconds of silence
    var timer = NSTimer()
    
    init(lengthInSeconds:Float, interruptable:Bool=false, title:String?=nil){
        self.lengthInSeconds = lengthInSeconds
        super.init(interruptable:interruptable, title: title ?? "Silence (\(lengthInSeconds) seconds)")
    }
    
    override func play(){
        if !timer.valid {
            timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(lengthInSeconds), target: self, selector: Selector("finished"), userInfo: nil, repeats: false)
            isPaused = false
        } else {
            timer.fire()
        }
    }
    
    override func pause(){
        isPaused = true
        timer.invalidate()
    }
}

class WaitForWord: Silence{
    /* simple actuation moment that does not call finished()
    until "yes" has been said in the interaction stage
    
    the "length" parameter now acts as a timing out function
    in case the user does not respond
    */
    
    var openEarsController : OpenEarsController
    
    init(wordsToRecognize: [String], lengthInSeconds: Float, interruptable:Bool=false, title:String?=nil){
        openEarsController = OpenEarsController(wordsToRecognize: wordsToRecognize)
        super.init(lengthInSeconds: lengthInSeconds, interruptable:interruptable, title: title ?? "Wait For \(wordsToRecognize)")
        openEarsController.events.listenTo("heardWord", action: self.heard)
        self.title = "WaitForWords: \(wordsToRecognize)"
    }
    
    override func play(){
        openEarsController.startListening()
        super.play()
    }
    
    override func pause(){
        openEarsController.stopListening()
        super.pause()
    }
    
    override func finished(){
        openEarsController.stopListening()
        super.finished()
    }
    
    func heard(information:Any?){
        // ?? - H
        self.eventManager.trigger("dataLabel", information: "heardWord")
        finished()
    }
    
    
}