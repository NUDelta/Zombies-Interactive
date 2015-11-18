//
//  Interaction.swift
//  ZombieRunX
//
//  Created by Henry Spindell on 10/30/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation

/// Compositional class that logically groups a number of Moments together with a title.
/// Can be inserted into stages in a number of ways -- see optional Stage parameters, and OpportunityManager.
class Interaction : NSObject {
    var moments: [Moment]
    var title: String
    
    init(moments: [Moment], title: String) {
        self.moments = moments
        self.title = title
    }
}