//
//  OpportunityManager.swift
//  ZombieRunX
//
//  Created by Henry Spindell on 11/7/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation
import CoreLocation


@objc protocol OpportunityManagerDelegate {

    optional func didUpdateInteractionQueue()
    func attemptInsertInteraction()
}

struct RegionInteractionPair: Equatable {
    var interaction:Interaction
    var region: CLCircularRegion
}

func ==(lhs: RegionInteractionPair, rhs: RegionInteractionPair) -> Bool {
    return lhs.interaction == rhs.interaction
}

class OpportunityManager: NSObject, CLLocationManagerDelegate {
    
    // TODO: don't add/play the same interactions twice (if you run in a circle, for example)
    //          or pause and start
    //       how are things popped? the first thing that is in the queue?
    //       things are added to queue once in a region, and removed once the region is left

    var interactionQueue: [RegionInteractionPair] = []
    var usedInteractions: [String] = []
    
    var locationManager = CLLocationManager()
    var regionBasedInteractions = [CLCircularRegion : Interaction]()

    
    init(regionBasedInteractions: [CLCircularRegion : Interaction]) {
        self.regionBasedInteractions = regionBasedInteractions
    }
    
    func contextSatisfiesInteraction(context: Context, interaction: Interaction) -> Bool {
        if interaction.requirement == nil {
            return false
        }
        
        // could change this to "score" the interaction by how close it is to satisfying
        // somewhere else a function could map all interaction scores from this fn into a priority queue
        let req = interaction.requirement!
        
        for condition in req.conditions {
            switch condition {
            case .MaxSpeed:
                if let maxSpeed = req.speed
                where context.speed > maxSpeed {
                    return false
                }
                break
            case .MinSpeed:
                if let minSpeed = req.speed
                where context.speed < minSpeed {
                    return false
                }
                break
            case .TimeElapsed:
                if let necessaryTimeElapsed = req.time
                where context.timeElapsed < necessaryTimeElapsed {
                    return false
                }
                break
                
            case .TimeRemaining:
                if let timeNeeded = req.time
                where context.timeRemaining < timeNeeded {
                    return false
                }
                break
            default:
                // some condition is not handled, we'll assume it isn't met
                return false
                break
            
            }
        }
        
        return true
    }
    
    func checkIfUserAlreadyInRegion(region: CLCircularRegion) {
        if let loc = locationManager.location?.coordinate where region.containsCoordinate(loc) {
            print("------------------------------------------------------------\nOPPORTUNITY MANAGER:\nCurrently in \"\(region.identifier)\" region")
            if let interaction = regionBasedInteractions[region] {
                pushInteractionIfNew(RegionInteractionPair(interaction: interaction, region: region))
            }
            print("------------------------------------------------------------")
        }
    }
    
    // TODO should be generalized to any interaction, not just region-based ones
    func pushInteractionIfNew(regionInteractionPair: RegionInteractionPair) {
        if usedInteractions.contains(regionInteractionPair.interaction.title) == false &&
            interactionQueue.contains(regionInteractionPair) == false {
            interactionQueue.append(regionInteractionPair)
            print("Adding \(regionInteractionPair.interaction.title) interaction to the queue")
        } else {
            print("Did not add \(regionInteractionPair.interaction.title) to the queue because it was used or in the queue previously")
        }
    }
    
    // Another option: don't even monitor for regions we already did interactions for
    func startMonitoringInteractionRegions() {
        for (region, _) in regionBasedInteractions {
            locationManager.startMonitoringForRegion(region)
            checkIfUserAlreadyInRegion(region)
        }
    }
    
    func stopMonitoringInteractionRegions() {
        for (region, _) in regionBasedInteractions {
            locationManager.stopMonitoringForRegion(region)
        }
    }
    
    // LocationManager delegate methods, these need testing
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("------------------------------------------------------------\nOPPORTUNITY MANAGER:\nEntered \"\(region.identifier)\" region")
        if let r = region as? CLCircularRegion,
            interaction = regionBasedInteractions[r] {
            pushInteractionIfNew(RegionInteractionPair(interaction: interaction, region: r))
        }
        print("------------------------------------------------------------")
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("------------------------------------------------------------\nOPPORTUNITY MANAGER:\nExited \"\(region.identifier)\" region")
        if let r = region as? CLCircularRegion, interaction = regionBasedInteractions[r],
        idx = interactionQueue.indexOf(RegionInteractionPair(interaction: interaction, region: r)) {
            interactionQueue.removeAtIndex(idx)
            print("Removed \(interaction.title) interaction from queue")
        }
        print("------------------------------------------------------------")
    }
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("------------------------------------------------------------\nOPPORTUNITY MANAGER:\nMonitoring failed for region with identifier: \(region?.identifier)\n------------------------------------------------------------")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("------------------------------------------------------------\nCLLocationManager failed with the following error: \(error)\n------------------------------------------------------------")
    }
    
    
    
    
    // TODO THIS LOGIC BELOW SHOULD BE ELSEWHERE
    
    var delegate: OpportunityManagerDelegate?
    var timer = NSTimer()
    
    func resetOpportunityTimer(information: Any?) {
        // FIXME this won't work as [String:AnyObject], even though it worked for datamanager?
        if let infoDict = information as? [String : String],
            durationString = infoDict["duration"],
            duration = Float(durationString) {
                
                if timer.valid {
                    timer.invalidate()
                }
                
                let midDurationTime = duration/2 // TODO randomize this a bit
                timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(midDurationTime), target: self, selector: Selector("attemptInsertInteraction"), userInfo: nil, repeats: false)
                print("------------------------------------------------------------\nOPPORTUNITY MANAGER:\nWill attempt to insert interaction in \(round(midDurationTime)) seconds\n------------------------------------------------------------")
        }
    }
    
    func attemptInsertInteraction() {
        print("------------------------------------------------------------\nOPPORTUNITY MANAGER:\nAttempting to insert an interaction from queue...")
        if interactionQueue.count > 0 {
            delegate?.attemptInsertInteraction()
        } else {
            print("Interaction queue is empty, cancelling attempt\n------------------------------------------------------------")
        }
        
    }
    
}
