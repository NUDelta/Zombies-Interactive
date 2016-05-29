//
//  SynthVoiceMoment.swift
//  ExperienceTestSingle
//
//  Created by Hyung-Soon on 5/11/16.
//  Copyright © 2016 Hyung-Soon. All rights reserved.
//

import Foundation
class SynthVoiceMoment : Moment {
    
    var speechSynthesizer: AVSpeechSynthesizer
    var speechUtterance: AVSpeechUtterance
    var voice: AVSpeechSynthesisVoice
    var _timer: NSTimer?
    
    init(title:String?=nil, content:String){
        
        speechSynthesizer = AVSpeechSynthesizer()
        speechUtterance = AVSpeechUtterance(string: content)
        
        //speechUtterance.rate = 0.25 //speed of speech
        //speechUtterance.pitchMultiplier = 1.25
        //speechUtterance.volume = 0.75
        //speechUtterance.
        
        //print(AVSpeechSynthesisVoice.speechVoices())
        
        voice = AVSpeechSynthesisVoice(language: "en-za")!
        speechUtterance.voice = voice
        //speechSynthesizer.speakUtterance(speechUtterance)
        //speechSynthesizer.pauseSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        super.init(title: title ?? "synth-voice:\(content)")
    }
    
    override func play(){
        //speechSynthesizer.continueSpeaking()
        speechSynthesizer.speakUtterance(speechUtterance)
        _timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(SynthVoiceMoment.checkVoiceFinished), userInfo: nil, repeats: true)
        super.play()
    }
    
    func checkVoiceFinished() {
        if ( !speechSynthesizer.speaking ) {
            _timer?.invalidate()
            super.finished()
        }
    }
    
    override func pause(){
        _timer?.invalidate()
        speechSynthesizer.pauseSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        super.pause()
    }
    
    override func finished(){
        _timer?.invalidate()
        super.finished()
    }
}