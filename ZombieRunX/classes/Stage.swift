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
    var isPlaying = false
    var moments:[Moment]
    var currentMomentIdx = 0
    var title: String
    let eventManager = EventManager()
    
    var currentMoment: Moment {
        get { return moments[currentMomentIdx] }
    }
    
    
    init(moments: [Moment], title: String) {
        self.moments = moments
        self.title = title
        super.init()
        for moment in moments{
            moment.eventManager.listenTo("nextSound", action: self.next)
        }
    }
    
    func play(){
        self.currentMoment.play()
    }
    
    func pause(){
        self.currentMoment.pause()
    }
    
    func next(){
        if (self.currentMomentIdx != (moments.count-1)){
            self.currentMomentIdx++
            print("  Starting moment: \(currentMomentTitle())")
            self.currentMoment.play()
            self.eventManager.trigger("newMoment", information: currentMomentTitle())
        } else {
            self.eventManager.trigger("stageFinished")
        }
    }
    
    func next(notification: NSNotification){
        self.next()
    }
    
    func currentMomentTitle() -> String {
        return self.currentMoment.title
    }

}

