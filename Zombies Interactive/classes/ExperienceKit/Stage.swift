//
//  MomentBlock.swift
//  Zombies Interactive
//
//  Created by Scott Cambo on 8/19/15.
//  Copyright (c) 2015 Scott Cambo. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}



// MomentBlock: a sub-experience comprised of moments
class MomentBlock: NSObject{
    
    // TODO: organize methods better
    
    var MomentBlockStarted = false
    var isPlaying = false
    var moments:[Moment]
    var currentMomentIdx = -1
    var title: String
    let eventManager = EventManager()
    var MomentBlockSimpleInsertionIndices: [Int]?
    var MomentBlockSimplePool: [MomentBlockSimple]?
    
    var currentMoment: Moment? {
        get { return moments[safe: currentMomentIdx] }
    }
    
    init(moments: [Moment], title: String, MomentBlockSimpleInsertionIndices:[Int]?=nil, MomentBlockSimplePool:[MomentBlockSimple]?=nil) {
        
        if MomentBlockSimplePool?.count < MomentBlockSimpleInsertionIndices?.count {
            fatalError("MomentBlockSimpleInsertionPool must be larger than the number of MomentBlockSimple insertion indices, as none will be repeated")
        }
        
        self.moments = moments
        self.title = title
        self.MomentBlockSimplePool = MomentBlockSimplePool
        self.MomentBlockSimpleInsertionIndices = MomentBlockSimpleInsertionIndices
        
        super.init()
        
        for moment in self.moments {
            moment.eventManager.listenTo("startingMoment", action: startingMoment)
            moment.eventManager.listenTo("nextMoment", action: nextMoment)
            moment.eventManager.listenTo("startingInterim", action: startingInterim)
            moment.eventManager.listenTo("startingSound", action: startingSound)
            moment.eventManager.listenTo("foundWorldObject", action: recordWorldObject)
        }
    }
    
    
    func insertAnyRandomMomentBlockSimples() {
        // should this be done at runtime to allow for better "audibles"?
        if let insertionIndices = MomentBlockSimpleInsertionIndices, let _ = self.MomentBlockSimplePool  {
            var numMomentsInserted = 0
            for idx in insertionIndices {
                let idxNew = idx + numMomentsInserted
                let randomMomentBlockSimpleIdx = self.MomentBlockSimplePool!.randomItemIndex()
                let randomMomentBlockSimple = self.MomentBlockSimplePool!.remove(at: randomMomentBlockSimpleIdx)
                
                eventManager.trigger("choseRandomMomentBlockSimple", information: ["MomentBlockSimpleTitle": randomMomentBlockSimple.title])
                self.insertMomentsAtIndex(randomMomentBlockSimple.moments, idx: idxNew)
                numMomentsInserted += randomMomentBlockSimple.moments.count
            }
            print("\n(MomentBlock.title:\(self.title)) MomentBlockSimples inserted at random (count:\(numMomentsInserted)). All moments:\n\(self.moments)")
        }
    }
    
    func startingMoment(_ information: Any?) {
        self.eventManager.trigger("startingMoment", information: information)
    }
    
    func startingSound() {
        self.eventManager.trigger("startingSound")
    }
    
    func startingInterim(_ information: Any?) {
        print("(MomentBlock::startingInterim) triggered")
        self.eventManager.trigger("startingInterim", information: information)
    }
    
    func start() {
        insertAnyRandomMomentBlockSimples()
        print("\n(MomentBlock::start) Starting MomentBlock: " + self.title)
        MomentBlockStarted = true
        self.nextMoment()
    }
    
    
    func play() {
        self.currentMoment?.play()
    }
    
    
    func pause() {
        self.currentMoment?.pause()
    }
    
    
    func nextMoment() {
        
        //[PERHAPS I SHOULD DO OPPORTUNITY CHECKING HERE INSTEAD]
        
        // TODO this is sloppy checking types, fix this
        if let _ = self.currentMoment as? SensorCollector {
            self.eventManager.trigger("sensorCollectorEnded")
        } else if let _ = self.currentMoment as? CollectorWithSound {
            self.eventManager.trigger("sensorCollectorEnded")
        }
        
        // stop the current moment's audio here instead of ExperienceManager?
        self.currentMomentIdx += 1
        
        if self.currentMomentIdx < moments.count {
            if let currentMoment = self.currentMoment as? SensorCollector {
                self.eventManager.trigger("sensorCollectorStarted",
                    information: ["sensors": currentMoment.sensors.rawValues, "label": currentMoment.dataLabel, "MomentBlockSimple": currentMoment.title])
            } else if let currentMoment = self.currentMoment as? CollectorWithSound {
                self.eventManager.trigger("sensorCollectorStarted",
                    information: ["sensors": currentMoment.sensors.rawValues, "label": currentMoment.dataLabel, "MomentBlockSimple": currentMoment.title])
            }
            print("\n--starting next moment (idx:\(currentMomentIdx))")
            self.currentMoment?.start()
        } else {
            print("Finished MomentBlock: \(self.title)")
            self.eventManager.trigger("MomentBlockFinished")
        }
    }
    
    
    func next(_ notification: Notification) {
        print("--next(???)--")
        self.nextMoment()
    }
    
    func recordWorldObject(_ information: Any?) {
        print(" MomentBlock.recordWorldObject called")
        self.eventManager.trigger("foundWorldObject", information: information)
    }
    
    func insertMomentsAtIndex(_ insertedMoments:[Moment], idx:Int) {
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

