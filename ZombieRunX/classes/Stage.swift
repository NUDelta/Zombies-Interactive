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
    var currentMoment = 0
    var title: String
    let eventManager = EventManager()
    
    init(moments: [Moment], title: String) {
        self.moments = moments
        self.title = title
        super.init()
        for moment in moments{
            moment.eventManager.listenTo("nextSound", action: self.next)
        }
    }
    
    func play(){
        print("Play moment #" + String(self.currentMoment))
        self.moments[currentMoment].play()
    }
    
    func pause(){
        self.moments[currentMoment].pause()
    }
    
    func next(){
        print("next()")
        if (self.currentMoment != (moments.count-1)){
            self.currentMoment++
            self.moments[currentMoment].play()
            self.eventManager.trigger("newMoment", information: currentMomentTitle())
        } else {
            self.eventManager.trigger("stageFinished")
        }
    }
    
    func next(notification: NSNotification){
        self.next()
    }
    
    func currentMomentTitle() -> String {
        return self.moments[currentMoment].title
    }

}

