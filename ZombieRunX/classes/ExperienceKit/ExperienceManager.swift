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
    optional func didBeginStage()
    optional func didFinishStage()
    optional func didFinishExperience()
}

/// Contains all logic for playing the experience, saving data, etc. Implement ExperienceManagerDelegate protocol for more custom logic.
class ExperienceManager: NSObject, OpportunityManagerDelegate {
    
    /*
    Questions
    
    Kit test-- can you make ZenWalk with this in 30 minutes?
    When we interrupt to collect data, how do we insert the moment?
    */
    
    var isPlaying = false
    var stages = [Stage]()
    var currentStageIdx = -1
    
    var dataManager: DataManager?  // should be optional whether their experience will collect data, especially location always
    var opportunityManager: OpportunityManager?
    
    var experienceStarted = false
    var experience: Experience?
    var delegate: ExperienceManagerDelegate?
    
    var audioSession: AVAudioSession = AVAudioSession.sharedInstance()

    
    var currentStage: Stage? {
        get { return stages[safe: currentStageIdx] }
    }
    
    
    init(title: String, stages: [Stage], regionBasedInteractions: [CLCircularRegion : Interaction]?=nil) {
        self.stages = stages
        self.experience = Experience()
        self.experience?.title = title
        self.dataManager = DataManager(experience: self.experience!)
        self.opportunityManager = OpportunityManager(regionBasedInteractions: regionBasedInteractions ?? [:])
        
        super.init()
        
        opportunityManager?.delegate = self
        
        for stage in stages{
            stage.eventManager.listenTo("stageFinished", action: self.nextStage)
            stage.eventManager.listenTo("startingInterim", action: self.setAVSessionForSilence)
            stage.eventManager.listenTo("startingSound", action: self.setAVSessionForSound)
            if let _ = opportunityManager {
                stage.eventManager.listenTo("startingMoment", action: self.opportunityManager!.resetOpportunityTimer)
            }
            
            if let dataManager = dataManager {
                stage.eventManager.listenTo("sensorCollectorStarted", action: dataManager.startCollecting)
                stage.eventManager.listenTo("sensorCollectorEnded", action: dataManager.stopCollecting)
                
                stage.eventManager.listenTo("foundPointOfInterest", action: dataManager.recordPointOfInterest)
            }
        }
        
        // Temporary fix because loading of mission view controller stops music
        do {
            try self.audioSession.setCategory(AVAudioSessionCategoryPlayback, withOptions: .MixWithOthers)
            try self.audioSession.setActive(false, withOptions: .NotifyOthersOnDeactivation)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    
    }
    

    // move some of this music logic to view controller, will likely be different for each app
    func setAVSessionForSilence() {
        // don't try to play the system player if it's in simulator
        #if (arch(i386) || arch(x86_64)) && os(iOS)
        #else
        MPMusicPlayerController.systemMusicPlayer().play()
        #endif
    }
    
    func setAVSessionForSound() {
        if self.audioSession.otherAudioPlaying {
            MPMusicPlayerController.systemMusicPlayer().pause()
        }
    }
    
    func start() {
        self.experience?.user = PFUser.currentUser()
        self.experience?.dateStarted = NSDate()
        self.experience?.completed = false
        self.experience?.saveInBackground()
        experienceStarted = true
        
        dataManager?.startUpdatingLocation()
        opportunityManager?.startMonitoringInteractionRegions()
        self.nextStage()
    }
    
    
    func play() {
        isPlaying = true
        
        dataManager?.startUpdatingLocation()
        opportunityManager?.startMonitoringInteractionRegions()
        
        if experienceStarted == false {
            self.start()
        } else {
            currentStage?.play()
        }
    }
    
    
    func pause() {
        dataManager?.stopUpdatingLocation()
        opportunityManager?.stopMonitoringInteractionRegions()
        
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
        opportunityManager?.stopMonitoringInteractionRegions()
        
        self.experience?.dateCompleted = NSDate()
        self.experience?.completed = true
        self.experience?.saveInBackground()
        
        do {
            try AVAudioSession.sharedInstance().setActive(false, withOptions: .NotifyOthersOnDeactivation)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        delegate?.didFinishExperience?()
        
        let systemPlayer = MPMusicPlayerController.systemMusicPlayer()
        if let _ = systemPlayer.nowPlayingItem {
            systemPlayer.play()
        }
    }

    
    func attemptInsertInteraction() {
        print("attempting to insert interaction dynamically")
        if let om = opportunityManager {
            print("Interaction queue: \(om.interactionQueue)")
        }
    }
    
    
}