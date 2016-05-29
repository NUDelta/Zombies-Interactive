//
//  OpportunityCheck.swift
//  ExperienceTestSingle
//
//  Created by Hyung-Soon on 5/5/16.
//  Copyright © 2016 Hyung-Soon. All rights reserved.
//

import Foundation
class OpportunityCheck: Moment{
    init(lengthInSeconds: Float, title:String?=nil){
        super.init(title: title ?? "OpportunityCheck (\(lengthInSeconds)sec)")
    }
    
    override func play(){
        super.play()
    }
    
    override func pause(){
        super.pause()
    }
    
    override func finished(){
        super.finished()
    }
}