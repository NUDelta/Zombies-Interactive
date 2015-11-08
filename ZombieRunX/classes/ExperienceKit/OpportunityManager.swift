//
//  OpportunityManager.swift
//  ZombieRunX
//
//  Created by Henry Spindell on 11/7/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation
import CoreLocation


protocol OpportunityManagerDelegate {

    func didUpdateInteractionQueue()
}

class OpportunityManager: NSObject, CLLocationManagerDelegate {
    
    // TODO: don't add/play the same interactions twice (if you run in a circle, for example)
    //       how are things popped? the first thing that is in the queue?
    //       things are added to queue once in a region, and removed once the region is left

    var interactionQueue: [Interaction] = []
    
    var locationManager = CLLocationManager()
    var regionBasedInteractions = [CLRegion : Interaction]()
    
    
    init(regionBasedInteractions: [CLRegion : Interaction]) {
        self.regionBasedInteractions = regionBasedInteractions
    }
    
    
    func startMonitoringInteractionRegions() {
        for (region, _) in regionBasedInteractions {
            locationManager.startMonitoringForRegion(region)
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
            print("Entered \"\(region.identifier)\"region")
        }
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            print("Exited \"\(region.identifier)\"region")
        }
    }
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("Monitoring failed for region with identifier: \(region?.identifier)")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location Manager failed with the following error: \(error)")
    }
}
