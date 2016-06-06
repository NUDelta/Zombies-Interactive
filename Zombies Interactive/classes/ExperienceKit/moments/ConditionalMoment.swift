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
    var momentBlock_true: MomentBlockSimple
    var momentBlock_false: MomentBlockSimple
    var moment_result: Moment?
    var conditionFunc: ()->Bool
    
    static var experienceManager: ExperienceManager?
    
    init(title:String?=nil, momentBlock_true:MomentBlockSimple, momentBlock_false:MomentBlockSimple,
         conditionFunc:()->Bool){
        self.momentBlock_true = momentBlock_true
        self.momentBlock_false = momentBlock_false
        self.conditionFunc = conditionFunc
        
        super.init(title: title ?? "condition-true:\(momentBlock_true.title)-false:\(momentBlock_false.title)")
    }
    
    override func play(){
        if conditionFunc() {
            //moment_result = moment_true
            print("..conditialMoment result:true")
            ConditionalMoment.experienceManager?.insertMomentBlockSimple(momentBlock_true)
        }
        else {
            //moment_result = moment_false
            print("..conditialMoment result:false")
            ConditionalMoment.experienceManager?.insertMomentBlockSimple(momentBlock_false)
        }
        //when the moment triggers the "nextMoment" message,
        //moment_result!.eventManager.listenTo("nextMoment", action: finished)
        //moment_result!.play()
        //super.play()
        finished()
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