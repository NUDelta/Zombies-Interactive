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


class ExperienceManager: NSObject {
    
    /*
    Questions
    
    We need to better parameterize the ExperienceManager and use parse keys constants, etc.
    
    When we interrupt to collect data, how do we insert the moment?
    
    */
    
    var isPlaying = false
    var stages = [Stage]()
    var currentStageIdx = -1
    var dataManager: DataManager?  // should be optional whether their experience will collect data
    var experienceStarted = false
    var experience: Experience?
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
            
            if let dataManager = dataManager {
                stage.eventManager.listenTo("dataMomentStarted", action: dataManager.startCollecting)
                stage.eventManager.listenTo("dataMomentEnded", action: dataManager.stopCollecting)
                
                stage.eventManager.listenTo("foundPointOfInterest", action: dataManager.recordPointOfInterest)
            }
        }
        
        // enable playing in background
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            print("AVAudioSession Category Playback OK")
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                print("AVAudioSession is Active")
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
    func start() {
        self.experience?.user = PFUser.currentUser()
        self.experience?.dateStarted = NSDate()
        self.experience?.saveInBackground()
        experienceStarted = true
        
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
    }

    
}