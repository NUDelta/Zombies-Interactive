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

class OpportunityManager: NSObject, CLLocationManagerDelegate {
    
    // TODO: don't add/play the same interactions twice (if you run in a circle, for example)
    //       how are things popped? the first thing that is in the queue?
    //       things are added to queue once in a region, and removed once the region is left

    var interactionQueue: [Interaction] = []
    
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
            print("will attempt to insert interaction in \(midDurationTime) seconds")
        }
    }
    
    func attemptInsertInteraction() {
        if interactionQueue.count > 0 {
            print("Attempting to insert an interaction")
            delegate?.attemptInsertInteraction()
        }
    }
    
    func checkIfUserAlreadyInRegion(region: CLCircularRegion) {
        if let loc = locationManager.location?.coordinate where region.containsCoordinate(loc) {
            print("Already in \"\(region.identifier)\" region")
            if let interaction = regionBasedInteractions[region] {
                interactionQueue.append(interaction)
            }
        }
    }
    
    func startMonitoringInteractionRegions() {
        for (region, _) in regionBasedInteractions {
            print("starting to monitor region")
            locationManager.startMonitoringForRegion(region)
            checkIfUserAlreadyInRegion(region)
        }
    }
    
    func stopMonitoringInteractionRegions() {
        for (region, _) in regionBasedInteractions {
            locationManager.stopMonitoringForRegion(region)
        }
    }
    
    // LocationManager delegate methods
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            print("Entered \"\(region.identifier)\" region")
        }
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            print("Exited \"\(region.identifier)\" region")
        }
    }
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("Monitoring failed for region with identifier: \(region?.identifier)")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location Manager failed with the following error: \(error)")
    }
}
