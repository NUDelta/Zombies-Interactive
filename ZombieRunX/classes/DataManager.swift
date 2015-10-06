//
//  DataManager.swift
//  ZombieRunX
//
//  Created by Henry Spindell on 10/2/15.
//  Copyright © 2015 Scott Cambo. All rights reserved.
//

import Foundation
import CoreLocation
import CoreMotion
import Parse

class DataManager : NSObject, CLLocationManagerDelegate {
    
    var experience: Experience?
    var motionManager = CMMotionManager()
    var locationManager = CLLocationManager()
    
    init(experience: Experience) {
        super.init()
        
        // Experience hasn't been saved at this point, so im not sure this pointer will work
        self.experience = experience
    
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
    }
    
    // Event data management
    
    
    
    
    
    // Motion data management
    
    
    
    
    // Location data management
    
    func startUpdatingLocation() {
        self.locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        self.locationManager.stopUpdatingLocation()
    }
    
    // called each time location is updated
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationUpdate = LocationUpdate()
        locationUpdate.experience = self.experience
        locationUpdate.location = PFGeoPoint(location: locations[0])
        locationUpdate.saveInBackground()
        
        // ? -H
        //alert MissionViewController to update stats
    }

}