//
//  MomentBlockSimple.swift
//  Zombies Interactive
//
//  Created by Henry Spindell on 10/30/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation

/// Compositional class that logically groups a number of Moments together with a title.
/// Can be inserted into MomentBlocks in a number of ways -- see optional MomentBlock parameters, and OpportunityManager.
class MomentBlockSimple : NSObject {
    var moments: [Moment]
    var title: String
    var requirement: Requirement? //use for calculating opportunities
    var canInsertImmediately: Bool = false
    
    init(moments: [Moment], title: String, requirement: Requirement?=nil, canInsertImmediately: Bool?=false) {
        self.moments = moments
        self.title = title
        self.requirement = requirement
        
        //for each moment, append the MomentBlockSimple title to the end
        //(so we can make debugging easier)
        for moment: Moment in self.moments {
            moment.title = moment.title + " (in:\(self.title))"
        }
    }
}