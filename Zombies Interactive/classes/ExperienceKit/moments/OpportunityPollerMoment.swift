//
//  OpportunityPollerMoment.swift
//  ExperienceTestSingle
//
//  Created by Hyung-Soon on 5/11/16.
//  Copyright © 2016 Hyung-Soon. All rights reserved.
//

import Foundation
class OpportunityPoller: SilentMoment {
 
    var objectFilters: Any
    var _scaffoldingManager: ScaffoldingManager
    var _lengthInSeconds: Double
    var _pollEveryXSeconds: Double
    var _timerPolling: NSTimer?
    var _timerWholeMoment: NSTimer?
    
    init(objectFilters:Any, lengthInSeconds: Double, pollEveryXSeconds: Double, scaffoldingManager: ScaffoldingManager, title:String?=nil){
        self.objectFilters = objectFilters
        _lengthInSeconds = lengthInSeconds
        _pollEveryXSeconds = pollEveryXSeconds
        _scaffoldingManager = scaffoldingManager
        super.init(title: title ?? "OpportunityPoller (\(lengthInSeconds)sec)")
    }
    
    override func play(){
        _timerPolling = NSTimer.scheduledTimerWithTimeInterval(_pollEveryXSeconds, target: self, selector: #selector(OpportunityPoller.checkOpportuntiy), userInfo: nil, repeats: true)
        _timerWholeMoment = NSTimer.scheduledTimerWithTimeInterval(_lengthInSeconds, target: self, selector: #selector(OpportunityPoller.finished), userInfo: nil, repeats: false)
        super.play()
    }
    
    func checkOpportuntiy() {
        print("...checking opportunity")
        let insertableMomentBlock = _scaffoldingManager.getPossibleInsertion(objectFilters)
        if insertableMomentBlock != nil {
            _scaffoldingManager._experienceManager.insertMomentBlockSimple(insertableMomentBlock!)
            print("--inserting opportuntistic MomentBlockSimple. ending current moment--")
            self.finished()
        }
    }
    
    override func pause(){
        super.pause()
    }
    
    override func finished(){
        _timerPolling?.invalidate()
        _timerWholeMoment?.invalidate()
        super.finished()
    }
    
}