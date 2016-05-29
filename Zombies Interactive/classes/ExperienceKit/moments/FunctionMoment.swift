//
//  FunctionMoment.swift
//  ExperienceTestSingle
//
//  Created by Hyung-Soon on 5/10/16.
//  Copyright © 2016 Hyung-Soon. All rights reserved.
//

import Foundation

//moment that just runs a function and finishes
class FunctionMoment: SilentMoment {
    var _execFunc: ()->Void
    
    init(title:String?=nil, execFunc:()->Void){
        self._execFunc = execFunc
        super.init(title: title ?? "execFunc moment")
    }
    
    override func play(){
        _execFunc()
        super.play()
        //just finish running right after the func
        super.finished()
    }
    
    override func pause(){
        super.pause()
    }
    
    override func finished(){
        super.finished()
    }
    
}