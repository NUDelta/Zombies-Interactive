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


protocol ExperienceManagerDelegate {
    func didFinishExperience()
}

class ExperienceManager: NSObject {
    
    /*
    Questions
    
    Kit test-- can you make ZenWalk with this in 30 minutes?
    When we interrupt to collect data, how do we insert the moment?
    */
    
    var isPlaying = false
    var stages = [Stage]()
    var currentStageIdx = -1
    var dataManager: DataManager?  // should be optional whether their experience will collect data
    var experienceStarted = false
    var experience: Experience?
    var delegate: ExperienceManagerDelegate?
    
    var audioSession: AVAudioSession = AVAudioSession.sharedInstance()

    
    var currentStage: Stage? {
        get { return stages[safe: currentStageIdx] }
    }
    
    
    init(title: String, stages: [Stage]) {
        self.stages = stages
        self.experience = Experience()
        self.experience?.title = title
        self.dataManager = DataManager(experience: self.experience!)

        super.init()
        
        for stage in stages{
            stage.eventManager.listenTo("stageFinished", action: self.nextStage)
            stage.eventManager.listenTo("startingSilence", action: self.setAVSessionForSilence)
            stage.eventManager.listenTo("startingSound", action: self.setAVSessionForSound)
            
            if let dataManager = dataManager {
                stage.eventManager.listenTo("dataMomentStarted", action: dataManager.startCollecting)
                stage.eventManager.listenTo("dataMomentEnded", action: dataManager.stopCollecting)
                
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
    
    
    func setAVSessionForSilence() {
        MPMusicPlayerController.systemMusicPlayer().play()
//        do {
//            try self.audioSession.setCategory(AVAudioSessionCategoryPlayback, withOptions: .MixWithOthers)
//            try self.audioSession.setActive(false, withOptions: .NotifyOthersOnDeactivation)
//            
//        } catch let error as NSError {
//            print(error.localizedDescription)
//        }
    }
    
    func setAVSessionForSound() {
        if self.audioSession.otherAudioPlaying {
            MPMusicPlayerController.systemMusicPlayer().pause()
        }
        
        // idea is to dynamically change options (single audio or mixing)
        // this method is better because it works with Spotify, Pandora, etc.
        // unfortunately the AVAudioSession API seems to be bugged
        // setActive (true) only works when phone isn't locked, even though code runs
        // might be because it's asynchronous? messes up really bad on radio static sound
//        do {
//            // this first line is only way to get rid of the .MixWithOthers option
//            try self.audioSession.setCategory(AVAudioSessionCategoryMultiRoute)
//            try self.audioSession.setCategory(AVAudioSessionCategoryPlayback)
//            try self.audioSession.setActive(true)
//            
//            print("  Setting to not mix with others")
//        } catch let error as NSError {
//            print(error.localizedDescription)
//        }
        
    }
    
    func start() {
        self.experience?.user = PFUser.currentUser()
        self.experience?.dateStarted = NSDate()
        self.experience?.completed = false
        self.experience?.saveInBackground()
        experienceStarted = true
        
        dataManager?.startUpdatingLocation()
        self.nextStage()
    }
    
    
    func play() {
        dataManager?.startUpdatingLocation()
        isPlaying = true
        
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
        
        do {
            try AVAudioSession.sharedInstance().setActive(false, withOptions: .NotifyOthersOnDeactivation)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        delegate?.didFinishExperience()
        
        let systemPlayer = MPMusicPlayerController.systemMusicPlayer()
        if let _ = systemPlayer.nowPlayingItem {
            systemPlayer.play()
        }
    }

    
}