//
//  Stage.swift
//  testZR
//
//  Created by Scott Cambo on 8/19/15.
//  Copyright (c) 2015 Scott Cambo. All rights reserved.
//

import Foundation
import AVFoundation
import AudioToolbox


class Moment: NSObject{
    var isInterruptable:Bool
    var isPaused = true;
    let events = EventManager()
    init(interruptable:Bool){
        self.isInterruptable = interruptable;
        println("Moment init()");
    }
    //func play()
    func play(){
        println("Moment play()")
        finished();
    }
    //func pause()
    func pause(){
        println("Moment pause()");
        self.isPaused = true;
    }
    
    //func finished()
    func finished(){
        println("Moment isFinished()");
        self.events.trigger("nextSound");
    }
    //func restart()
    func restart(){
        
    }
}

class Sound: Moment, AVAudioPlayerDelegate{
    /* Implement this as an AudioPlayer */
    var fileName:String
    //var playerItem:AVPlayerItem
    var player:AVAudioPlayer
    
    init(file: String, interruptable:Bool){
        self.fileName = file
        print("Sound init()");
        //initalize AVAudioPlayer with file variable
        var error:NSError?
        var soundLocation = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(file, ofType: "wav")!)
        println(soundLocation)
        self.player = AVAudioPlayer(contentsOfURL: soundLocation, error: &error)
        super.init(interruptable:interruptable);

        
        self.player.delegate = self;
        self.player.prepareToPlay();
        

    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        println("finished playing \(flag)")
        super.finished();
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: NSError!) {
        println("\(error.localizedDescription)")
    }
    
    override func play(){
        self.player.play();
        isPaused = false;
    }
    
    override func pause(){
        self.player.pause();
        isPaused = true;
    }
    
}

class Silence: Moment{
    /* placeholder for silence in a "stage" 
       Runs an NSTimer object*/
    var length: Float; // seconds of silence
    var timer = NSTimer();
    
    init(length:Float, interruptable:Bool){
        self.length = length;
        println("Silence init()")
        super.init(interruptable:interruptable);
    }
    
    override func play(){
        if !timer.valid {
            timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(length), target: self, selector: Selector("finished"), userInfo: nil, repeats: false);
            isPaused = false;
        } else {
            timer.fire();
        }
    }
    
    override func pause(){
        println("pausing silent moment");
        isPaused = true;
        timer.invalidate();
    }
}

class waitForYes: Silence{
    /* simple actuation moment that does not call finished()
       until "yes" has been said in the interaction stage
    
        the "length" parameter now acts as a timing out function
        in case the user does not respond
    */
    
    var oeController = OpenEarsController(wordsToRecognize: ["yes"]);
    
    override init(length: Float, interruptable:Bool){
        super.init(length: length, interruptable:interruptable);
        oeController.events.listenTo("heardWord", action: self.heard);
    }
    
    override func play(){
        // start OpenEarsListener
        oeController.startListening();
        //start timeout
        super.play()
    }
    
    override func pause(){
        oeController.stopListening();
        super.pause();
    }
    
    override func finished(){
        oeController.stopListening();
        super.finished();
    }
    
    func heard(information:Any?){
        finished();
    }
    
    
}

class AppStage: NSObject{
    var isPlaying = false
    var moments:[Moment];
    var currentMoment = 0;
    var audioSession:AVAudioSession!
    let events = EventManager()
    
    init(moments: [Moment]) {
        self.moments = moments;
        super.init();
        for moment in moments{
            moment.events.listenTo("nextSound", action: self.next);
        }
    }
    
    func play(){
        println("Play moment #" + String(self.currentMoment));
        self.moments[currentMoment].play();
    }
    
    func pause(){
        self.moments[currentMoment].pause();
    }
    
    func next(){
        println("next() called");
        if (self.currentMoment != (moments.count-1)){
            self.currentMoment += 1;
            self.moments[currentMoment].play();
        } else {
            self.events.trigger("stagefinished");
        }
    }
    
    func next(notification: NSNotification){
        self.next();
    }

}

