//
//  OpportunityManager.swift
//  Zombies Interactive
//
//  Created by Henry Spindell on 11/7/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation


@objc protocol OpportunityManagerDelegate {

    optional func didUpdateInteractionQueue()
    func attemptInsertInteraction()
}




class OpportunityManager: NSObject {
    
    var interactionPool: [Interaction]
    
    init(interactionPool: [Interaction]) {
        self.interactionPool = interactionPool
    }
    
    func getBestFitInteraction(context: Context) -> Interaction? {
        var highestScore = 0
        var highestScoreIdx = -1
        
        for (idx, interaction) in interactionPool.enumerate() {
            let fitScore = interactionContextFitScore(context, interaction: interaction)
            if fitScore > highestScore {
                highestScore = fitScore
                highestScoreIdx = idx
            }
        }
        
        if highestScoreIdx == -1 {
            return nil
        }
        
        return interactionPool.removeAtIndex(highestScoreIdx)
    }
    
    
    func interactionContextFitScore(context: Context, interaction: Interaction) -> Int {
        if interaction.requirement == nil {
            return 0
        }
        
        // could change this to "score" the interaction by how close it is to satisfying
        // somewhere else a function could map all interaction scores from this fn into a priority queue
        let req = interaction.requirement!
        
        for condition in req.conditions {
            switch condition {
            case .MaxSpeed:
                if let maxSpeed = req.speed
                where context.speed > maxSpeed {
                    return 0
                }
                break
            case .MinSpeed:
                if let minSpeed = req.speed
                where context.speed < minSpeed {
                    return 0
                }
                break
            case .TimeElapsed:
                if let necessaryTimeElapsed = req.seconds
                where context.timeElapsed < necessaryTimeElapsed {
                    return 0
                }
                break
                
            case .TimeRemaining:
                if let timeNeeded = req.seconds
                where context.timeRemaining < timeNeeded {
                    return 0
                }
                break
                
            case .InRegion:
                if let region = req.region,
                userLocation = context.location
                where region.containsCoordinate(userLocation) == false {
                    return 0
                }
                break
            
            }
        }
        
        return req.conditions.count
    }
    
}
