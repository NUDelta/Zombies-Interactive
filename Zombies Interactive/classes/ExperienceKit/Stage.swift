//
//  Stage.swift
//  Zombies Interactive
//
//  Created by Scott Cambo on 8/19/15.
//  Copyright (c) 2015 Scott Cambo. All rights reserved.
//

import Foundation


// Stage: a sub-experience comprised of moments
class Stage: NSObject{
    
    // TODO: organize methods better
    
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
        self.interactionInsertionIndices = interactionInsertionIndices
        
        super.init()
        
        for moment in self.moments {
            moment.eventManager.listenTo("startingMoment", action: startingMoment)
            moment.eventManager.listenTo("nextMoment", action: nextMoment)
            moment.eventManager.listenTo("startingInterim", action: startingInterim)
            moment.eventManager.listenTo("startingSound", action: startingSound)
            moment.eventManager.listenTo("foundWorldObject", action: recordWorldObject)
        }
    }
    
    
    func insertAnyRandomInteractions() {
        // should this be done at runtime to allow for better "audibles"?
        if let insertionIndices = interactionInsertionIndices, _ = self.interactionPool  {
            var numMomentsInserted = 0
            for idx in insertionIndices {
                let idxNew = idx + numMomentsInserted
                let randomInteractionIdx = self.interactionPool!.randomItemIndex()
                let randomInteraction = self.interactionPool!.removeAtIndex(randomInteractionIdx)
                
                eventManager.trigger("choseRandomInteraction", information: ["interactionTitle": randomInteraction.title])
                self.insertMomentsAtIndex(randomInteraction.moments, idx: idxNew)
                numMomentsInserted += randomInteraction.moments.count
            }
            print("\nInteractions inserted at random:\n\(self.moments)")
        }
    }
    
    func startingMoment(information: Any?) {
        self.eventManager.trigger("startingMoment", information: information)
    }
    
    func startingSound() {
        self.eventManager.trigger("startingSound")
    }
    
    func startingInterim(information: Any?) {
        self.eventManager.trigger("startingInterim", information: information)
    }
    
    func start() {
        insertAnyRandomInteractions()
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
        
        // TODO this is sloppy checking types, fix this
        if let _ = self.currentMoment as? SensorCollector {
            self.eventManager.trigger("sensorCollectorEnded")
        } else if let _ = self.currentMoment as? CollectorWithSound {
            self.eventManager.trigger("sensorCollectorEnded")
        }
        
        // stop the current moment's audio here instead of ExperienceManager?
        self.currentMomentIdx++
        
        if self.currentMomentIdx < moments.count {
            if let currentMoment = self.currentMoment as? SensorCollector {
                self.eventManager.trigger("sensorCollectorStarted",
                    information: ["sensors": currentMoment.sensors.rawValues, "label": currentMoment.dataLabel, "interaction": currentMoment.title])
            } else if let currentMoment = self.currentMoment as? CollectorWithSound {
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
    
    func recordWorldObject(information: Any?) {
        print(" stage.recordWorldObject called")
        self.eventManager.trigger("foundWorldObject", information: information)
    }
    
    func insertMomentsAtIndex(insertedMoments:[Moment], idx:Int) {
        for moment in insertedMoments {
            moment.eventManager.listenTo("startingMoment", action: self.startingMoment)
            moment.eventManager.listenTo("nextMoment", action: self.nextMoment)
            moment.eventManager.listenTo("startingInterim", action: self.startingInterim)
            moment.eventManager.listenTo("startingSound", action: self.startingSound)
            moment.eventManager.listenTo("foundWorldObject", action: self.recordWorldObject)
        }
        
        self.moments = self.moments[0..<idx] + insertedMoments + self.moments[idx..<self.moments.count]
    }
    
}

