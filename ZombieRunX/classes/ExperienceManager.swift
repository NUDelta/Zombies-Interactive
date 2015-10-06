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


class ExperienceManager: NSObject, CLLocationManagerDelegate {
    
    /*
    Questions
    
    When we interrupt to collect data, how do we insert the moment?
    
    */
    
    var isPlaying = false
    var stages = [Stage]()
    var currentStageIdx = 0
    var currentMomentIdx = 0
    var dataManager: DataManager?
    var experienceStarted = false
    var experience: Experience?
    
    var currentStage: Stage {
        get { return stages[currentStageIdx] }
    }
    
    // should we track currentMoment?
    
    // why have this?
    var currentMomentTitle: String = ""

    
    init(title: String, stages: [Stage]) {
        self.stages = stages
        self.experience = Experience()
        self.experience?.title = title
        self.dataManager = DataManager(experience: self.experience!)
        
        super.init()
        
        for stage in stages{
            stage.eventManager.listenTo("stageFinished", action: self.nextStage)
            for moment in stage.moments{
                // can we just keep track of the current moment on our own?
                moment.eventManager.listenTo("newMoment", action: self.setCurrentMomentTitle)
            }
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
        print("playing " + currentStage.title)
        currentStage.play()
        
        self.currentMomentTitle = currentStage.currentMomentTitle()
        isPlaying = true
    }
    
    // TODO change this to a set{} block?
    func setCurrentMomentTitle(title:Any?){
        self.currentMomentTitle = String(title)
    }
    
    func pause(){
        currentStage.pause()
        isPlaying = false
    }
    
    
    func nextStage(){
        print("nextStage()")
        
        if (self.currentStageIdx < stages.count - 1) {
            self.currentStageIdx++
            self.play()
        } else {
            self.finishExperience()
        }
    }
    
    func finishExperience(){
        print("finishExperience()")
        
        self.experience?.dateFinished = NSDate()
        self.experience?.finished = true
        self.experience?.saveInBackground()
        dataManager?.stopUpdatingLocation()
    }

    
}