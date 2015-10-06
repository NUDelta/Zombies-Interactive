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
    var isInterruptable: Bool
    var isPaused = true
    var title: String!
    let eventManager = EventManager()
    
    init(interruptable:Bool){
        print("Moment init()")
        
        self.isInterruptable = interruptable
    }
    

    func play(){
        print("Moment play()")
        
        finished()
    }

    func pause(){
        print("Moment pause()")
        
        self.isPaused = true
    }
    
    func finished(){
        print("Moment finished()")
        
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
    
    init(file: String, interruptable:Bool){
        print("Sound init()", terminator: "")
        
        self.fileName = file

        //initalize AVAudioPlayer with file variable
        let soundLocation = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(file, ofType: "mp3")!)
        print(soundLocation)
        do {
            self.player = try AVAudioPlayer(contentsOfURL: soundLocation)
        } catch let error as NSError {
            print(error.localizedDescription)
            self.player = nil
        }
        super.init(interruptable:interruptable)
        self.title = fileName
        
        
        self.player?.delegate = self
        self.player?.prepareToPlay()
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        print("audioPlayerDidFinishPlaying \(flag)")
        
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
    /* placeholder for silence in a "stage"
    Runs an NSTimer object*/
    var length: Float // seconds of silence
    var timer = NSTimer()
    
    init(length:Float, interruptable:Bool){
        print("Silence init()")
        
        self.length = length
        super.init(interruptable:interruptable)
        self.title = "Silence : " + String(stringInterpolationSegment: self.length)
    }
    
    override func play(){
        if !timer.valid {
            timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(length), target: self, selector: Selector("finished"), userInfo: nil, repeats: false)
            isPaused = false
        } else {
            timer.fire()
        }
    }
    
    override func pause(){
        print("Silent pause()")
        
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
    
    init(wordsToRecognize: [String], length: Float, interruptable:Bool){
        openEarsController = OpenEarsController(wordsToRecognize: wordsToRecognize)
        super.init(length: length, interruptable:interruptable)
        openEarsController.events.listenTo("heardWord", action: self.heard)
        self.title = "WaitForWords: \(wordsToRecognize)"
    }
    
    override func play(){
        // start OpenEarsListener
        openEarsController.startListening()
        //start timeout
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