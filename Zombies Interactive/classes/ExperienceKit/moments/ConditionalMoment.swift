//
//  ConditionalMoment.swift
//  ExperienceTestSingle
//
//  Created by Hyung-Soon on 5/5/16.
//  Copyright © 2016 Hyung-Soon. All rights reserved.
//

import Foundation

//conditional branching of moments based upon a true/false function
class ConditionalMoment: Moment{
    var moment_true: Moment
    var moment_false: Moment
    var moment_result: Moment?
    var conditionFunc: ()->Bool
    
    init(title:String?=nil, moment_true:Moment, moment_false:Moment, conditionFunc:()->Bool){
        self.moment_true = moment_true
        self.moment_false = moment_false
        self.conditionFunc = conditionFunc
        
        super.init(title: title ?? "condition-true:\(moment_true.title)-false:\(moment_false.title)")
    }
    
    override func play(){
        if conditionFunc() {
            moment_result = moment_true
            print("..conditialMoment result:true")
        }
        else {
            moment_result = moment_false
            print("..conditialMoment result:false")
        }
        //when the moment triggers the "nextMoment" message,
        moment_result!.eventManager.listenTo("nextMoment", action: finished)
        moment_result!.play()
        super.play()
    }
    
    override func pause(){
        if let _ = moment_result {
            moment_result!.pause()
        }
        super.pause()
    }
    
    override func finished(){
        super.finished()
    }
}