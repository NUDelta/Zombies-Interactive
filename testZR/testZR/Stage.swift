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
    var title:String!;
    let events = EventManager()
    init(interruptable:Bool){
        self.isInterruptable = interruptable;
        print("Moment init()");
    }
    //func play()
    func play(){
        print("Moment play()")
        finished();
    }
    //func pause()
    func pause(){
        print("Moment pause()");
        self.isPaused = true;
    }
    
    //func finished()
    func finished(){
        print("Moment isFinished()");
        self.events.trigger("nextSound");
    }
    //func restart()
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
        self.fileName = file
        print("Sound init()", terminator: "");
        //initalize AVAudioPlayer with file variable
        let soundLocation = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(file, ofType: "mp3")!)
        print(soundLocation)
        do {
            self.player = try AVAudioPlayer(contentsOfURL: soundLocation)
        } catch let error as NSError {
            print(error.localizedDescription)
            self.player = nil
        }
        super.init(interruptable:interruptable);
        self.title = fileName;

        
        self.player?.delegate = self;
        self.player?.prepareToPlay();
        

    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        print("finished playing \(flag)")
        super.finished();
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        if let error = error {
            print(error.localizedDescription)
        }
    }
    
    override func play(){
        self.player?.play();
        isPaused = false;
    }
    
    override func pause(){
        self.player?.pause();
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
        print("Silence init()")
        super.init(interruptable:interruptable);
        self.title = "Silence : " + String(stringInterpolationSegment: self.length);
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
        print("pausing silent moment");
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
        self.title = "waitForYes";
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
        self.events.trigger("dataLabel", information: "heardYes");
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
        print("Play moment #" + String(self.currentMoment));
        self.moments[currentMoment].play();
    }
    
    func pause(){
        self.moments[currentMoment].pause();
    }
    
    func next(){
        print("next() called");
        if (self.currentMoment != (moments.count-1)){
            self.currentMoment += 1;
            self.moments[currentMoment].play();
            self.events.trigger("newMoment", information: self.moments[currentMoment].title);
        } else {
            self.events.trigger("stagefinished");
        }
    }
    
    func next(notification: NSNotification){
        self.next();
    }

}

