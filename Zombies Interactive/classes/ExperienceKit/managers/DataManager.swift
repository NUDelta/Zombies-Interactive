//
//  DataManager.swift
//  Zombies Interactive
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
        Speed = "speed",
        MotionActivity = "motion_activity"
}

class DataManager : NSObject, CLLocationManagerDelegate {
    
    var experience: Experience?
    var locationManager = CLLocationManager()
    var motionActivityManager = CMMotionActivityManager()
    var dataEvent: DataEvent?
    var currentLocation: CLLocation?
    
    
    init(experience: Experience) {
        super.init()
        
        self.experience = experience
    
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = 1 // distance runner must move in meters to call update eventconfi
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestAlwaysAuthorization()
    }
    
    // TODO: why is this function running for no reason sometimes..?
//    func recordWorldObject(information: Any?) {
//        print(information)
//        print("  datamanager->recording world object")
//        let worldObject = WorldObject()
//        if let infoDict = information as? [String : String] {
//            worldObject.trigger = infoDict["trigger"]
//            worldObject.label = infoDict["label"]
//            worldObject.interaction = infoDict["interaction"]
//        }
//        worldObject.experience = experience
//        worldObject.location = PFGeoPoint(location: locationManager.location)
//        worldObject.verified = true
//        worldObject.saveInBackground()
//    }
    
    
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
                case Sensor.MotionActivity.rawValue:
                    print(" recording \(sensor)")
                    
                    if(CMMotionActivityManager.isActivityAvailable()) {
                        self.motionActivityManager.startActivityUpdatesToQueue(NSOperationQueue.mainQueue()) { data in
                            if let data = data {
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.saveMotionActivityUpdate(data)
                                }
                            }
                        }
                    }
                    
                default:
                    print("  data type \(sensor) does not exist")
                }
            }
        }
    }
    
    
    func stopCollecting(){
        print("  stopped recording data")
        self.motionActivityManager.stopActivityUpdates()
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
        currentLocation = locations[0]
        let locationUpdate = LocationUpdate()
        locationUpdate.experience = self.experience
        locationUpdate.location = PFGeoPoint(location: currentLocation)
        locationUpdate.altitude = currentLocation!.altitude
        locationUpdate.speed = currentLocation!.speed
        locationUpdate.horizontalAccuracy = currentLocation!.horizontalAccuracy
        locationUpdate.saveInBackground()
    }
    
    func saveMotionActivityUpdate(data:CMMotionActivity) {
        var activityState = "other"
        if(data.stationary == true) {
            activityState = "stationary"
        } else if (data.walking == true) {
            activityState = "walking"
        } else if (data.running == true) {
            activityState = "running"
        } else if (data.automotive == true) {
            activityState = "automotive"
        } else if (data.cycling == true) {
            activityState = "cycling"
        } else if data.unknown == true {
            activityState = "unknown"
        }
        
        let motionActivityUpdate = MotionActivityUpdate()
        motionActivityUpdate.experience = self.experience
        motionActivityUpdate.location = PFGeoPoint(location: locationManager.location)
        motionActivityUpdate.state = activityState
        motionActivityUpdate.confidence = data.confidence.rawValue
        motionActivityUpdate.saveInBackground()
    }
    

}