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
    var experience_title:String = "";
    
    var stage_title:String = "";
    var moment_title:String = "";
    var data_label = "";
    
    init(experience_title: String, stages: [AppStage]) {
        self.stages = stages
        self.currentStage = 0
        self.experience_title = experience_title;
        
        super.init();
        
        /* Initialize any data managers that will be needed, i.e. things like LocationManager and MotionManager */
        //set up location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization();
        
        for stage in stages{
            stage.events.listenTo("stagefinished", action: self.nextStage);
            for moment in stage.moments{
                moment.events.listenTo("newMoment", action: self.setMomentTitle);
            }
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
            self.experience["mission_name"] = self.experience_title
            self.experience["hasFinished"] = false;// <-- quick hard code hack, see note
            // Note : ^^ the mission_name should get changed to be set when the developer
            // builds the mission
            self.experience.saveInBackground();
        }
        print("playing stage #" + String(currentStage));
        stages[currentStage].play();
        self.moment_title = stages[currentStage].moments[stages[currentStage].currentMoment].title;
        self.stage_title = "Stage #1"
        isPlaying = true;
    }
    
    func setMomentTitle(information:Any?){
        self.moment_title = String(stringInterpolationSegment: information);
        //clear data label so that it doesn't persist until later.  This may need to change for future versions with more complex notions of data labels.
        self.data_label = "";
    }
    
    func pause(){
        stages[currentStage].pause();
        isPlaying = false;
    }
    
    func getStage() -> AppStage{
        return stages[currentStage]
    }
    
    func nextStage(){
        print("nextStage() called");
        if (self.currentStage < stages.count - 1) {
            self.currentStage = self.currentStage + 1;
            self.play();
            self.stage_title = "Stage #" + String(self.currentStage+1);
        } else {
            self.expFinished();
        }
    }
    
    func expFinished(){
        print("experience finished()");
        self.experience["time_finished"] = NSDate();
        self.experience["hasFinished"] = true;
        self.experience.saveInBackground();
        locationManager.stopUpdatingLocation();
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // convert CLLocation to PFGeoPoint and add to expLocations
        let currLoc = locations[0] 
        let point = PFGeoPoint(location: currLoc);
        let pLocation = PFObject(className: "Location");
        self.expLocations.append(point);

        pLocation["point"] = point;
        pLocation["user"] = self.currentUser;
        pLocation["time"] = NSDate();
        pLocation["experience_id"] = self.experience;
        pLocation["mission"] = self.experience["mission_name"];
        pLocation["stage"] = self.stage_title;
        pLocation["moment"] = self.moment_title;
        pLocation["data"] = self.data_label;
        pLocation.saveInBackground();
        
        //alert MissionViewController to update stats
        
    }
    
    func setDataLabel(information: Any?){
        
    }
    
}