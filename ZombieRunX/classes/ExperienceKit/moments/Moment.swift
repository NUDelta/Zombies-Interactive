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

class Moment: NSObject {
    
    /*
        Either give this more functionality or make it "abstract"?
        Why have a class where play() calls finished(), shouldn't let that be used


    */
    
    var momentStarted = false
    var isPaused = true
    var title: String
    let eventManager = EventManager()
    override var description:String {
        return self.title
    }
    
    init(title: String){
        // WARNING: DO NOT INIT A Moment(), USE ONLY SUBCLASSES - need to find solution
        self.title = title
    }
    
    func start(){
        print("  Starting moment: \(self.title)")
        momentStarted = true
        self.play()
    }

    func play(){
        self.isPaused = false
    }

    func pause(){
        self.isPaused = true
    }
    
    func finished(){
        print("  Finished moment: \(self.title)")
        
        self.eventManager.trigger("nextMoment")
    }
}





