//
//  SpeechListener.swift
//  ZombieRunX
//
//  Created by Henry Spindell on 11/3/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation

class SpeechListener: TriggerListener {
    
    var openEarsController : OpenEarsController
    
    init(title:String?=nil, lengthInSeconds: Float, dataLabel:String, recordMultiple:Bool=false, wordsToRecognize: [String]){
        self.openEarsController = OpenEarsController(wordsToRecognize: wordsToRecognize)
        let trigger: Trigger = .Speech
        
        super.init(title: title, lengthInSeconds: lengthInSeconds, dataLabel: dataLabel,
            trigger: trigger, recordMultiple: recordMultiple)
    }
    
    override func start() {
        openEarsController.events.listenTo("heardWord", action: self.didHearWord)
        super.start()
    }
    
    override func play() {
        openEarsController.startListening()
        super.play()
    }
    
    override func pause() {
        openEarsController.stopListening()
        super.pause()
    }
    
    override func finished() {
        openEarsController.stopListening()
        super.finished()
    }
    
    func didHearWord(information:Any?){
        print("  heard one of the specified words")
        didReceiveTrigger()
    }
    
}