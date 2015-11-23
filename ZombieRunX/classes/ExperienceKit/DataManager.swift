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

/// Sensor types that can be used to specify what kind of data to collect.
/// Each type maps to a class in Parse, see DataEvent for more detail.
enum Sensor: String {
    case Location = "location",
        Accel = "accel",
        Altitude = "altitude",
        Speed = "speed"
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
        
        print("  Recording point of interest")
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
        sensors = infoDict["sensors"] as? [String],
        interaction = infoDict["interaction"] as? String,
        label = infoDict["label"] as? String {
            self.dataEvent?.sensors = sensors
            self.dataEvent?.interaction = interaction
            self.dataEvent?.label = label
            
            for sensor in sensors {
                switch sensor {
                    // we may not actually check this one because location is always recording
                    //  in case we want to show them their path, etc.
                case Sensor.Location.rawValue:
                    print("  recording \(sensor)")
                case Sensor.Accel.rawValue:
                    print("  recording \(sensor)")
                case Sensor.Altitude.rawValue:
                    print("  recording \(sensor)")
                case Sensor.Speed.rawValue:
                    print("  recording \(sensor)")
                default:
                    print("  data type \(sensor) does not exist")
                }
            }
        }
    }
    
    
    func stopCollecting(){
        self.dataEvent?.endDate = NSDate()
        self.dataEvent?.saveInBackground()
    }
    
    
    
    func startUpdatingLocation() {
        self.locationManager.startUpdatingLocation()
    }
    
    
    func stopUpdatingLocation() {
        self.locationManager.stopUpdatingLocation()
    }
    
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations[0]
        let locationUpdate = LocationUpdate()
        locationUpdate.experience = self.experience
        locationUpdate.location = PFGeoPoint(location: currentLocation)
        locationUpdate.altitude = currentLocation.altitude
        locationUpdate.speed = currentLocation.speed
        locationUpdate.saveInBackground()
    }

}