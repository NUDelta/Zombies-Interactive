//
//  Stage.swift
//  ZombieRunX
//
//  Created by Scott Cambo on 8/19/15.
//  Copyright (c) 2015 Scott Cambo. All rights reserved.
//

import Foundation

// Stage: a sub-experience comprised of moments
class Stage: NSObject{
    var stageStarted = false
    var isPlaying = false
    var moments:[Moment]
    var currentMomentIdx = -1
    var title: String
    let eventManager = EventManager()
    
    var currentMoment: Moment? {
        get { return moments[safe: currentMomentIdx] }
    }
    
    
    init(moments: [Moment], title: String) {
        self.moments = moments
        self.title = title
        super.init()
        for moment in moments{
            moment.eventManager.listenTo("nextMoment", action: self.nextMoment)
            moment.eventManager.listenTo("foundPointOfInterest", action: self.recordPointOfInterest)
        }
    }
    
    
    func start() {
        print("\nStarting stage: " + self.title)
        stageStarted = true
        self.nextMoment()
    }
    
    
    func play() {
        self.currentMoment?.play()
    }
    
    
    func pause() {
        self.currentMoment?.pause()
    }
    
    
    func nextMoment() {
        
        if let currentMoment = self.currentMoment as? DataMoment {
            self.eventManager.trigger("dataMomentEnded", information: currentMoment.dataTypes)
        }
        
        // stop the current moment's audio here instead of ExperienceManager?
        self.currentMomentIdx++
        
        if self.currentMomentIdx < moments.count {
            if let currentMoment = self.currentMoment as? DataMoment {
                self.eventManager.trigger("dataMomentStarted", information: currentMoment.dataTypes)
            }
            self.currentMoment?.start()
        } else {
            print("Finished stage: \(self.title)")
            self.eventManager.trigger("stageFinished")
        }
    }
    
    
    func next(notification: NSNotification) {
        self.nextMoment()
    }
    
    func recordPointOfInterest(information: Any?) {
        self.eventManager.trigger("foundPointOfInterest", information: information)
    }
}

