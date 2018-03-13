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
import AVFoundation

/// Sensor types that can be used to specify what kind of data to collect.
/// Each type maps to a class in Parse, see sensorMoment for more detail.
enum Sensor: String {
    case Location = "location",
        Accel = "accel",
        Altitude = "altitude",
        Speed = "speed",
        MotionActivity = "motion_activity"
}

@objc protocol DataManagerDelegate {
    @objc optional func didUpdateData()
}

class DataManager : NSObject, CLLocationManagerDelegate {
    
    var delegate: DataManagerDelegate?
    var experience: Experience?
    var _experienceManager: ExperienceManager
    var locationManager = CLLocationManager()
    var motionActivityManager = CMMotionActivityManager()
    var sensorMoment: SensorMoment?
    var currentLocation: CLLocation?
    var currentHeading: CLLocationDirection?
    var currentMotionActivity:CMMotionActivity?
    var currentMotionActivityState: String?
    let synthesizer : AVSpeechSynthesizer = AVSpeechSynthesizer()
    var playedMoments = Set<String>()
    
    // New snippets
    let demoId = "1"
    // var locationManager: CLLocationManager! = CLLocationManager()
    // let serverAddress = "https://8011ac33.ngrok.io"
    var momentString = ""
    var momentPlayed = false
    var lastLocationPostedAt : Double = Date().timeIntervalSinceReferenceDate
    @IBOutlet weak var momentTextLabel: UILabel!

    init(experienceManager: ExperienceManager, experience: Experience) {
        self._experienceManager = experienceManager
        
        super.init()
        
        self.experience = experience
        
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = 10 // distance runner must move in meters to call update eventconfi
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingHeading()
        
    }
    
    func updateWorldObject(_ object:PFObject, information:Any?, validated:Bool?)
    {
        if validated != nil {
            if validated! == true {
                object.incrementKey("validatedTimes", byAmount: 1)
            }
            else {
                object.incrementKey("invalidatedTimes", byAmount: 1)
            }
        }
        object.saveInBackground()
    }
    
    func pushWorldObject(_ information: Any?) {
       // print("(DM::pushWorldObject): \(information)")
        let worldObject = WorldObject()
        if let infoDict = information as? [String : String] {
            //worldObject.trigger = infoDict["trigger"]
            worldObject.interaction = infoDict["interaction"]
            worldObject.label = infoDict["label"]
            worldObject.variation = Int(infoDict["variation"] ?? "0") as NSNumber? //default value:0
            //worldObject.MomentBlockSimple = infoDict["MomentBlockSimple"]
        }
        //worldObject.experience = experience
        worldObject.location = PFGeoPoint(location: locationManager.location)
        worldObject.verified = true
        worldObject.verifiedTimes = 0
        
        //worldObject.saveInBackground()
        
        //certain conditions where error does occur, and maybe some not
        //maybe locatinons are misssing parameters, etc. 
        worldObject.saveInBackground  {
            (success, error) in
            if success == true {
          //      print("Score created with ID: \(worldObject.objectId)")
            } else {
                print(error)
            }
        }
    }
    
    func startCollecting(_ information:Any?){
        self.sensorMoment = SensorMoment()
        self.sensorMoment?.experience = self.experience
        self.sensorMoment?.startDate = Date()
        
        if let infoDict = information as? [String : AnyObject],
        let sensors = infoDict["sensors"] as? [String],
        let MomentBlockSimple = infoDict["MomentBlockSimple"] as? String,
        let label = infoDict["label"] as? String {
            self.sensorMoment?.sensors = sensors
            self.sensorMoment?.MomentBlockSimple = MomentBlockSimple
            self.sensorMoment?.label = label
            
            for sensor in sensors {
                switch sensor {
                    // we may not actually check this one because location is always recording
                    //  in case we want to show them their path, etc.
                case Sensor.Location.rawValue:
                    print(" (DataManager::startCollecting)   recording \(sensor)")
                case Sensor.Accel.rawValue:
                    print(" (DataManager::startCollecting)   recording \(sensor)")
                case Sensor.Altitude.rawValue:
                    print(" (DataManager::startCollecting)   recording \(sensor)")
                case Sensor.Speed.rawValue:
                    print(" (DataManager::startCollecting)   recording \(sensor)")
                case Sensor.MotionActivity.rawValue:
                    print(" (DataManager::startCollecting)   recording \(sensor)")
                    
                    if(CMMotionActivityManager.isActivityAvailable()) {
                        self.motionActivityManager.startActivityUpdates(to: OperationQueue.main) { data in
                            if let data = data {
                                DispatchQueue.main.async {
                                    self.saveMotionActivityUpdate(data)
                                }
                            }
                        }
                    }
                    else {
                        print("..CMMotionActivityManager not available..")
                    }
                    
                default:
                    print(" (DataManager::startCollecting)  data type \(sensor) does not exist")
                }
            }
        }
    }
    
    
    func stopCollecting(){
        print("  stopped recording data")
        self.motionActivityManager.stopActivityUpdates()
        self.sensorMoment?.endDate = Date()
        self.sensorMoment?.saveInBackground()
    }
    
    func startUpdatingLocation() {
        print("start updating location")
        self.locationManager.startUpdatingLocation()
    }
    
    
    func stopUpdatingLocation() {
        print("stop updating location")
        self.locationManager.stopUpdatingLocation()
    }
    
    func getMoments(){
        CommManager.instance.getRequest(route: "moments", parameters: [:]) {
            json in
            print("received moment")
            print(json)
            // if there is no nearby search region with the item not found yet, server returns {"result":0}
            //            if json.index(forKey: "found") != nil {
            //                let loc = json["loc"] as! [String:Any]
            //                let coord = loc["coordinates"] as! [Double]
            //                let id = json["_id"] as! [String:Any]
            //                //                    if regionId == id["$oid"] as! String {
            //                self.searchRegion = LostItemRegion(requesterName: json["user"] as! String, item: json["item"] as! String, itemDetail: json["detail"] as! String, lat: coord[1], lon: coord[0], id: id["$oid"] as! String)
            //                self.center.post(name: NSNotification.Name(rawValue: "updatedDetail"), object: nil, userInfo:nil)
            //                    }
        }
    }
    func buildMoment(_ moment:[String:Any]){
        if moment["prompt"] != nil{
            self.momentString = moment["prompt"] as! String
            if (self.momentString != "" && !self.playedMoments.contains(self.momentString)){
                DispatchQueue.main.async {
                    let expandMoment:SynthVoiceMoment = SynthVoiceMoment(title: "newMoment", isInterruptable: false, content: self.momentString)
                    let block_body = MomentBlockSimple(moments: [Sound(fileNames:["radio_static"]), expandMoment, Sound(fileNames:["radio_static"])], title:"expand moment block", canInsertImmediately: true)
                    // Insert moment into experience manager
                self._experienceManager.insertMomentBlockSimple(block_body)
                self.playedMoments.insert(self.momentString)
                }
            }
        }
    }
    
    // SEND A LOCATION along with run_id, RECIEVE THE "BEST" MOMENT FROM OPPORTUNITY MANANGER ON BACKEND
    func postLocation(_ params:[String:Any]) {
        var ret = [String:Any]()
        CommManager.instance.urlRequest(route: "location", parameters: params, completion: {
            json in
            ret = json
            
            // Receive json and create moment
            print("Getting right moment:")
            print(ret)
            self.buildMoment(ret)
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("..datamanager::updating location..")
        //this is where DataManager.currentLocation gets updated
        currentLocation = locations[0]
        
        // Snippets from new Location manager:
        let userLocation:CLLocation = locations[0];
        let long = userLocation.coordinate.longitude;
        let lat = userLocation.coordinate.latitude;
        var json = [String:Any]();
        json["longitude"] = long
        json["latitude"] = lat
        json["run_id"] = self._experienceManager.run_id
        json["user_id"] = self._experienceManager.user_id
        
        print("long: \(long), lat: \(lat)")
        
        // Post latitude and longitude, recieve moment, insert moment!
        postLocation(json)
        
        //Check Parse if locations are pushing
        let locationUpdate = LocationUpdate() //intialise Parse object
        locationUpdate.experience = self.experience
        locationUpdate.location = PFGeoPoint(location: currentLocation)
        locationUpdate.altitude = currentLocation!.altitude as NSNumber?
        locationUpdate.speed = currentLocation!.speed as NSNumber?
        locationUpdate.horizontalAccuracy = currentLocation!.horizontalAccuracy as NSNumber?
        //locationUpdate.incrementKey(<#T##key: String##String#>, byAmount: <#T##NSNumber#>)
        locationUpdate.saveInBackground()
        
        delegate?.didUpdateData?()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        var h = newHeading.magneticHeading
        let h2 = newHeading.trueHeading // will be -1 if we have no location info
        if h2 >= 0 {
            h = h2
        }
        let cards = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        var dir = "N"
        for (ix, card) in cards.enumerated() {
            if h < 45.0/2.0 + 45.0*Double(ix) {
                dir = card
                break
            }
        }
        //if self.lab.text != dir {
        //    self.lab.text = dir
        //}
        //print(dir)
        currentHeading = h
        
        //print("\(h) \(h2) ")
        //print("heading(dir):\(dir)")
        delegate?.didUpdateData?()
    }
    
    //called by: Stage::nextMoment() -> DataManager::startCollecting()
    func saveMotionActivityUpdate(_ data:CMMotionActivity) {
        //print("..datamanager::updating motion activity..")
        currentMotionActivity = data
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
        currentMotionActivityState = activityState
        
        let motionActivityUpdate = MotionActivityUpdate()
        motionActivityUpdate.experience = self.experience
        motionActivityUpdate.location = PFGeoPoint(location: locationManager.location)
        motionActivityUpdate.state = activityState
        motionActivityUpdate.confidence = data.confidence.rawValue as NSNumber?
        motionActivityUpdate.saveInBackground()
        
        delegate?.didUpdateData?()
    }
    

}
