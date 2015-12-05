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
    var delegate: OpportunityManagerDelegate?
    var timer = NSTimer()
    
    init(regionBasedInteractions: [CLCircularRegion : Interaction]) {
        self.regionBasedInteractions = regionBasedInteractions
    }
    
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
    
    func checkIfUserAlreadyInRegion(region: CLCircularRegion) {
        if let loc = locationManager.location?.coordinate where region.containsCoordinate(loc) {
            print("------------------------------------------------------------\nOPPORTUNITY MANAGER:\nCurrently in \"\(region.identifier)\" region")
            if let interaction = regionBasedInteractions[region] {
                pushInteractionIfNew(RegionInteractionPair(interaction: interaction, region: region))
            }
            print("------------------------------------------------------------")
        }
    }
    
    
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
}
