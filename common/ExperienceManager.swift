//
//  ExperienceManager.swift
//
//
//  Created by Scott Cambo on 8/17/15.
//
//

import Foundation
import AVFoundation
import CoreLocation
import Parse

class ExperienceManager: NSObject, CLLocationManagerDelegate {
    var isPlaying = false;
    var stages = [AppStage]();
    var currentStage:Int;
    var pausedStage:AppStage?;
    var locationManager:CLLocationManager!
    var expLocations : [PFGeoPoint] = [];
    var experienceStarted = false;
    var currentUser = PFUser.currentUser();
    var experience:PFObject!;
    init(stages: [AppStage]) {
        self.stages = stages
        self.currentStage = 0
        
        super.init();
        
        /* Initialize any data managers that will be needed, i.e. things like LocationManager and MotionManager */
        //set up location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization();
        
        for stage in stages{
            stage.events.listenTo("stagefinished", action: self.nextStage);
        }
    }
    
    func play(){
        if !experienceStarted{ // initial starting of the experience
            //start any data managers that are needed globally (probably just LocationManager)
            self.locationManager.startUpdatingLocation();
            
            //initialize data for the experience and hold reference for updating things
            // like hasFinished, time_ended
            self.experience = PFObject(className: "Experience");
            self.experience["User"] = self.currentUser;
            self.experience["time_started"] = NSDate();
            self.experience["mission_name"] = "Hospital"
            self.experience["hasFinished"] = false;// <-- quick hard code hack, see note
            // Note : ^^ the mission_name should get changed to be set when the developer
            // builds the mission
            self.experience.saveInBackground();
        }
        println("playing stage #" + String(currentStage));
        stages[currentStage].play();
        isPlaying = true;
    }
    
    func pause(){
        stages[currentStage].pause();
        isPlaying = false;
    }
    
    func getStage() -> AppStage{
        return stages[currentStage]
    }
    
    func nextStage(){
        println("nextStage() called");
        if (self.currentStage < count(stages) - 1) {
            self.currentStage = self.currentStage + 1;
            self.play();
        } else {
            self.expFinished();
        }
    }
    
    func expFinished(){
        println("experience finished()");
        self.experience["time_finished"] = NSDate();
        self.experience["hasFinished"] = true;
        self.experience.saveInBackground();
        locationManager.stopUpdatingLocation();
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        // convert CLLocation to PFGeoPoint and add to expLocations
        var currLoc = locations[0] as! CLLocation
        let point = PFGeoPoint(location: currLoc);
        var pLocation = PFObject(className: "Location");
        self.expLocations.append(point);

        pLocation["point"] = point;
        pLocation["user"] = self.currentUser;
        pLocation["time"] = NSDate();
        pLocation["experience_id"] = self.experience;
        pLocation["mission"] = self.experience["mission_name"];
        pLocation.saveInBackground();
        
        //alert MissionViewController to update stats
        
    }
    
}