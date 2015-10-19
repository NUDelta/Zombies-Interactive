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


enum DataCollectionType: String {
    case Location = "location",
        Accel = "accel"
}

class DataManager : NSObject, CLLocationManagerDelegate {
    
    var experience: Experience?
//    var motionManager = CMMotionManager()
    var locationManager = CLLocationManager()
    
    
    init(experience: Experience) {
        super.init()
        
        // Experience hasn't been saved at this point, so i'm not sure this pointer will work
        self.experience = experience
    
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
    }
    
    func recordPointOfInterest(information: Any?) {
        
        print("  recording point of interest")
        let pointOfInterest = PointOfInterest()
        if let infoDict = information as? [String : String] {
            pointOfInterest.trigger = infoDict["trigger"]
            pointOfInterest.label = infoDict["label"]
        }
        pointOfInterest.experience = experience
        pointOfInterest.location = PFGeoPoint(location: locationManager.location)
        pointOfInterest.saveInBackground()
    }
    
    
    func startCollecting(information:Any?){
        if let dataTypes = information as? [DataCollectionType]{
            for dataType in dataTypes {
                switch dataType {
                    // we may not actually check this one because location is always recording
                    //  in case we want to show them their path, etc.
                case .Location:
                    print("  recording \(dataType.rawValue)")
                case .Accel:
                    print("  recording \(dataType.rawValue)")
                }
            }
        }
    }
    
    
    func stopCollecting(){
        // just stop everything (except location)
        // we could save info on what exactly we were recording if necessary
        print("  no longer recording data")
    }
    
    
    // Event data management (things that happens instantaneously)
    
    
    // Motion data management
    
    
    // Location data management
    
    func startUpdatingLocation() {
        self.locationManager.startUpdatingLocation()
    }
    
    
    func stopUpdatingLocation() {
        self.locationManager.stopUpdatingLocation()
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationUpdate = LocationUpdate()
        locationUpdate.experience = self.experience
        locationUpdate.location = PFGeoPoint(location: locations[0])
        locationUpdate.saveInBackground()
    }

}