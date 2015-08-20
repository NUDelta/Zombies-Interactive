//
//  ExperienceManager.swift
//
//
//  Created by Scott Cambo on 8/17/15.
//
//

import Foundation
import AVFoundation
class ExperienceManager {
    var isPlaying = false;
    var stages = [AppStage]();
    var currentStage:Int;
    init(stages: [AppStage]) {
        self.stages = stages
        self.currentStage = 0
        for stage in stages{
            stage.events.listenTo("finished", action: self.nextStage);
        }
    }
    
    func play(){
        println("playing stage #" + String(currentStage));
        stages[currentStage].play();
        isPlaying = true;
    }
    
    func pause(){
        stages[currentStage].pause();
        isPlaying = false;
    }
    
    func getStage() -> AppStage{
        return stages[currentStage]
    }
    
    func nextStage(){
        println("nextStage() called");
        self.currentStage = self.currentStage + 1;
        self.play();
    }
    
}