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
    
    When we interrupt to collect data, how do we insert the moment?
    
    */
    
    var isPlaying = false
    var stages = [Stage]()
    var currentStageIdx = 0
    var dataManager: DataManager?
    var experienceStarted = false
    var experience: Experience?
    var currentStage: Stage {
        get { return stages[currentStageIdx] }
    }
    

    
    init(title: String, stages: [Stage]) {
        self.stages = stages
        self.experience = Experience()
        self.experience?.title = title
        self.dataManager = DataManager(experience: self.experience!)
        
        super.init()
        
        for stage in stages{
            stage.eventManager.listenTo("stageFinished", action: self.nextStage)
        }
    }
    
    func play(){
        
        if experienceStarted == false {
            //start any data managers that are needed globally (probably just LocationManager)
            dataManager?.startUpdatingLocation()
            
            self.experience?.user = PFUser.currentUser()
            self.experience?.finished = false
            self.experience?.saveInBackground()
        }
        
        currentStage.play()
        
        isPlaying = true
    }
    
    
    func pause(){
        currentStage.pause()
        isPlaying = false
    }
    
    
    func nextStage(){
        print("Finished stage: " + currentStage.title)
        if (self.currentStageIdx < stages.count - 1) {
            self.currentStageIdx++
            print("\nStarting stage: " + currentStage.title)
            print("  Starting moment: " + currentStage.moments[0].title)
            self.play()
        } else {
            self.finishExperience()
        }
    }
    
    func finishExperience(){
        print("\nFinished experience")
        // TODO do something when it's over on the UI, and reset all local data
        
        self.experience?.dateFinished = NSDate()
        self.experience?.finished = true
        self.experience?.saveInBackground()
        dataManager?.stopUpdatingLocation()
    }

    
}