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
    var interactionInsertionIndices: [Int]?
    var interactionPool: [Interaction]?
    
    var currentMoment: Moment? {
        get { return moments[safe: currentMomentIdx] }
    }
    
    
    init(moments: [Moment], title: String, interactionInsertionIndices:[Int]?=nil, interactionPool:[Interaction]?=nil) {
        if interactionPool?.count < interactionInsertionIndices?.count {
            fatalError("interactionInsertionPool must be larger than the number of interaction insertion indices, as none will be repeated")
        }
        
        self.moments = moments
        self.title = title
        self.interactionPool = interactionPool
        
        // TODO go through interactionInsertionIndices, at each one insert a random interaction into the stage
        // and then remove that interaction from the pool
        // ExperienceManager needs to know which have been used as well in case the person wants the same options at multiple stages
        if let insertionIndices = interactionInsertionIndices, _ = self.interactionPool  {
            var numMomentsInserted = 0
            for idx in insertionIndices {
                let idxNew = idx + numMomentsInserted
                let randomInteractionIdx = self.interactionPool!.randomItemIndex()
                let randomInteraction = self.interactionPool!.removeAtIndex(randomInteractionIdx)
                
                // mark randomInteraction.title as used in experience
                
                self.moments = self.moments[0..<idxNew] + randomInteraction.moments + self.moments[idxNew..<self.moments.count]
                numMomentsInserted += randomInteraction.moments.count
                print(self.moments)
            }
        }
        
        
        
        
        super.init()
        for moment in self.moments{
            moment.eventManager.listenTo("nextMoment", action: self.nextMoment)
            moment.eventManager.listenTo("startingInterim", action: self.startingInterim)
            moment.eventManager.listenTo("startingSound", action: self.startingSound)
            moment.eventManager.listenTo("foundPointOfInterest", action: self.recordPointOfInterest)
        }
    }
    
    func startingSound() {
        self.eventManager.trigger("startingSound")
    }
    
    func startingInterim() {
        self.eventManager.trigger("startingInterim")
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
        
        if let _ = self.currentMoment as? SensorCollector {
            self.eventManager.trigger("sensorCollectorEnded")
        }
        
        // stop the current moment's audio here instead of ExperienceManager?
        self.currentMomentIdx++
        
        if self.currentMomentIdx < moments.count {
            if let currentMoment = self.currentMoment as? SensorCollector {
                self.eventManager.trigger("sensorCollectorStarted",
                    information: ["sensors": currentMoment.sensors.rawValues, "label": currentMoment.dataLabel, "interaction": currentMoment.title])
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

