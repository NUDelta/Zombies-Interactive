//
//  ExperienceManager.swift
//
//
//  Created by Scott Cambo on 8/17/15.
//
//

import Foundation
import AVFoundation
import CoreLocation
import Parse
import CoreMotion
import MediaPlayer

/// Protocol for suscribing to ExperienceManager events
@objc protocol ExperienceManagerDelegate {
    optional func didBeginMoment()
    optional func didFinishMoment()
    optional func didBeginInterim()
    optional func didFinishInterim()
    optional func didBeginSound()
    optional func didFinishSound()
    optional func didBeginStage()
    optional func didFinishStage()
    optional func didFinishExperience()
    optional func didAddDestination(destLocation: CLLocationCoordinate2D, destinationName: String)
}

/// Contains all logic for playing the experience, saving data, etc. Implement ExperienceManagerDelegate protocol for more custom logic.
class ExperienceManager: NSObject, OpportunityManagerDelegate {
    
    var isPlaying = false
    var stages = [Stage]()
    var currentStageIdx = -1
    
    // should be optional whether their experience will collect data, especially location always
    var dataManager: DataManager?
    var opportunityManager: OpportunityManager?
    
    var experienceStarted = false
    var experience: Experience?
    var delegate: ExperienceManagerDelegate?
    
    var opportunityTimer = NSTimer()
    
    
    var currentStage: Stage? {
        get { return stages[safe: currentStageIdx] }
    }
    
    var currentContext: Context {
        get {
            return Context(
                        timeElapsed: 0, // TODO implement time elapsed
                        timeRemaining: 0, // TODO estimate time remaining based on time elapsed and total time (precalculated)
                        speed: dataManager?.currentLocation?.speed,
                        location: dataManager?.currentLocation?.coordinate)
        }
    }
    
    
    init(title: String, stages: [Stage], interactionPool: [Interaction]?=nil) {
        self.stages = stages
        self.experience = Experience()
        self.experience?.title = title
        self.dataManager = DataManager(experience: self.experience!)
        if let _ = interactionPool {
            opportunityManager = OpportunityManager(interactionPool: interactionPool!)
        }
        
        
        super.init()
        
        for stage in stages{
            stage.eventManager.listenTo("stageFinished", action: nextStage)
            stage.eventManager.listenTo("startingInterim", action: handleInterimStart)
            stage.eventManager.listenTo("startingSound", action: handleSoundStart)
            
            if let dataManager = dataManager {
                stage.eventManager.listenTo("sensorCollectorStarted", action: dataManager.startCollecting)
                stage.eventManager.listenTo("sensorCollectorEnded", action: dataManager.stopCollecting)
                
//                stage.eventManager.listenTo("foundWorldObject", action: dataManager.recordWorldObject)
            }
        }
        
        // Temporary fix because loading of mission view controller stops music

    
    }
    
    func handleInterimStart(information: Any?) {
        delegate?.didBeginInterim?()
        
        setAVSessionForSilence()
        if let _ = opportunityManager {
            resetOpportunityTimer(information)
        }
    }
    
    func handleSoundStart(information: Any?) {
        delegate?.didBeginSound?()
        setAVSessionForSound()
    }

    // move some of this music logic to view controller, will likely be different for each app
    func setAVSessionForSilence() {

    }
    
    func setAVSessionForSound() {

    }
    
    func start() {
        print("\nExperience started")
        isPlaying = true
        self.experience?.user = PFUser.currentUser()
        self.experience?.dateStarted = NSDate()
        self.experience?.completed = false
        self.experience?.saveInBackground()
        experienceStarted = true
        
        self.nextStage()
        dataManager?.startUpdatingLocation()
    }
    
    
    func play() {
        isPlaying = true
        
        dataManager?.startUpdatingLocation()
        
        if experienceStarted == false {
            self.start()
        } else {
            currentStage?.play()
        }
    }
    
    
    func pause() {
        dataManager?.stopUpdatingLocation()
        
        isPlaying = false
        currentStage?.pause()
    }
    
    
    func nextStage() {
        self.currentStageIdx++

        if self.currentStageIdx < stages.count {
            self.currentStage?.start()
        } else {
            self.finishExperience()
        }
    }
    
    
    func finishExperience() {
        print("\nFinished experience")
        dataManager?.stopUpdatingLocation()
        
        self.experience?.dateCompleted = NSDate()
        self.experience?.completed = true
        self.experience?.saveInBackground()
  
        delegate?.didFinishExperience?()
    }
    
    
    func resetOpportunityTimer(information: Any?) {
        // FIXME this won't work as [String:AnyObject], even though it worked for datamanager?
        if let infoDict = information as? [String : String],
        durationString = infoDict["duration"],
        duration = Float(durationString) {
                
            if opportunityTimer.valid {
                opportunityTimer.invalidate()
            }
                
            let midDurationTime = duration/2 // TODO randomize this a bit?
            opportunityTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(midDurationTime), target: self, selector: Selector("attemptInsertInteraction"), userInfo: nil, repeats: false)
            print("  Opportunity check in \(round(midDurationTime)) seconds")
        }
    }

    
    func attemptInsertInteraction() {
        print("  Checking opportunity...")
        if let om = opportunityManager,
        stage = currentStage,
        moment = stage.currentMoment,
        interaction = om.getBestFitInteraction(currentContext)
        where isPlaying && moment.isInterruptable {
            print("  Inserting interaction '\(interaction.title)'.")
            stage.insertMomentsAtIndex(interaction.moments, idx: stage.currentMomentIdx + 1)
            
            // add pin on map if it's location based
            //delegate?.didAddDestination?(interaction.requirement.region.center, destinationName: interaction.requirement.region.identifier)
            
            moment.finished()
        } else {
            print("  No interactions fit the current context.")
        }
    }
}