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

extension CollectionType where Generator.Element == DataCollectionType {
    var rawValues: [String] {
        return self.map {
            (let dataType) -> String in
            return dataType.rawValue
        }
    }
}

class DataManager : NSObject, CLLocationManagerDelegate {
    
    var experience: Experience?
//    var motionManager = CMMotionManager()
    var locationManager = CLLocationManager()
    var dataEvent: DataEvent?
    
    
    init(experience: Experience) {
        super.init()
        
        self.experience = experience
    
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = 1 // won't get update unless they moved 1 meter
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
    }
    
    func recordPointOfInterest(information: Any?) {
        
        print("  recording point of interest")
        let pointOfInterest = PointOfInterest()
        if let infoDict = information as? [String : String] {
            pointOfInterest.trigger = infoDict["trigger"]
            pointOfInterest.label = infoDict["label"]
            pointOfInterest.interaction = infoDict["interaction"]
        }
        pointOfInterest.experience = experience
        pointOfInterest.location = PFGeoPoint(location: locationManager.location)
        pointOfInterest.saveInBackground()
    }
    
    
    func startCollecting(information:Any?){
        self.dataEvent = DataEvent()
        self.dataEvent?.experience = self.experience
        self.dataEvent?.startDate = NSDate()
        
        if let infoDict = information as? [String : AnyObject],
        dataTypes = infoDict["dataTypes"] as? [String],
        interaction = infoDict["interaction"] as? String,
        label = infoDict["label"] as? String {
            self.dataEvent?.dataTypes = dataTypes
            self.dataEvent?.interaction = interaction
            self.dataEvent?.label = label
            
            for dataType in dataTypes {
                switch dataType {
                    // we may not actually check this one because location is always recording
                    //  in case we want to show them their path, etc.
                case DataCollectionType.Location.rawValue:
                    print("  recording \(dataType)")
                case DataCollectionType.Accel.rawValue:
                    print("  recording \(dataType)")
                default:
                    print("data type does not exist")
                }
            }
        }
    }
    
    
    func stopCollecting(){
        self.dataEvent?.endDate = NSDate()
        self.dataEvent?.saveInBackground()
        // just stop everything (except location)
        // we could save info on what exactly we were recording if necessary
        print("  no longer recording data")
    }
    
    
    // Event data management (things that happens instantaneously)
    
    
    // Motion data management
    
    
    // Location data management
    
    func startUpdatingLocation() {
        self.locationManager.startUpdatingLocation()
        print("starting location updates")
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