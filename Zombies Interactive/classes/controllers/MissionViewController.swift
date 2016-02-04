//
//  ViewController.swift
//  Zombies Interactive
//
//  Created by Scott Cambo on 8/17/15.
//  Copyright (c) 2015 Scott Cambo. All rights reserved.
//

import UIKit
import Parse
import MapKit
import MediaPlayer
import CoreLocation

// should implement an ExperienceManager delegate for events like silenceDidStart

class MissionViewController: UIViewController, MKMapViewDelegate, ExperienceManagerDelegate {

    var missionTitle: String = ""
    var experienceManager:ExperienceManager!
    var musicPlayer:MPMusicPlayerController?
    
    var currentAnnotation: MKAnnotation?
    
    @IBOutlet weak var controlLabel: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nextMomentButton: UIButton!
    
    @IBAction func previousMoment(sender: AnyObject) {
        // FIX this requires too much knowledge of internals for another developer to use
        let currentMoment = self.experienceManager.currentStage?.currentMoment
        (currentMoment as? Sound)?.player?.stop()
        
        if self.experienceManager.isPlaying == false {
            self.controlLabel.setTitle("Pause", forState: .Normal)
        }
        
        currentMoment?.finished()
    }
    
    @IBAction func nextMoment(sender: AnyObject) {
        // FIX this requires too much knowledge of internals for another developer to use
        
        let currentMoment = self.experienceManager.currentStage?.currentMoment
        (currentMoment as? Sound)?.player?.stop()
        
        if self.experienceManager.isPlaying == false {
            self.controlLabel.setTitle("Pause", forState: .Normal)
        }

        currentMoment?.finished()
    }
    
    @IBAction func controlButton(sender: AnyObject) {
        if let label = self.controlLabel.titleLabel?.text where label == "Start" {
            self.experienceManager.start()
            self.controlLabel.setTitle("Pause", forState: .Normal)
            #if DEBUG
            nextMomentButton.hidden = false
            #endif
        } else if self.controlLabel.titleLabel!.text == "Resume" {
            print("  Experience resumed")
            self.experienceManager.play()
            self.controlLabel.setTitle("Pause", forState: .Normal)
        } else {
            print("  Experience paused")
            self.experienceManager.pause()
            self.controlLabel.setTitle("Resume", forState: .Normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: "back:")
        self.navigationItem.leftBarButtonItem = newBackButton;
        
        
        CLLocationManager().requestAlwaysAuthorization()
        
        view.backgroundColor = UIColor(red:0.24, green:0.24, blue:0.25, alpha:1)
        
        
        // regions -- should be pulled from Parse in the future, probably
        // get only "verified" ones
        let chickenShackLocation = CLLocationCoordinate2D(latitude: 42.052860617171845, longitude: -87.68747791910707)
        let chickenShackRegion = CLCircularRegion(center: chickenShackLocation, radius: 300, identifier: "Chicken Shack")
        
        let techLocation = CLLocationCoordinate2D(latitude: 42.057789, longitude: -87.676150)
        let techRegion = CLCircularRegion(center: techLocation, radius: 1000, identifier: "Tech Institute")
        
        
        let mission1Intro = Sound(fileNames: ["ZRS1M1v2"])
        let mission1Part02 = Sound(fileNames: ["M-E01-02"])
        let mission1Part03 = Sound(fileNames: ["M-E01-03"])
        let mission1Part04 = Sound(fileNames: ["M-E01-04"])
        let mission1Part05 = Sound(fileNames: ["M-E01-05"])
        let mission1Part06 = Sound(fileNames: ["M-E01-06"])
        let mission2Preview = Sound(fileNames: ["NextTimeS1M3"])
        
        
        // Interaction definitions
        
        // Identify vantage points
        let identifyBuildings = KnockListener(title: "Identify Vantage Points",
                                            lengthInSeconds: 2.minutesToSeconds,
                                            dataLabel: "tall_building",
                                            recordMultiple: true,
                                            requireDoubleKnock: true)
        let knockForBuildingsRequirement = Requirement(conditions: [.TimeElapsed], seconds: -1)
        let knockForBuildings = Interaction(moments: [Sound(fileNames: ["radio_static", "vantage_points_1", "radio_static"]),
                                                      identifyBuildings,
                                                      Sound(fileNames: ["radio_static", "vantage_points_2", "radio_static"])],
                                            title: "Identify Vantage Points",
                                            requirement: knockForBuildingsRequirement)
        
        // Find tree cover and stretch
        let stretchAtTree = SensorCollector(lengthInSeconds: 90, title: "Get Cover and Stretch", dataLabel: "tree", sensors: [.Location])
        let getCoverAtTree = Interaction(moments: [Sound(fileNames: ["find_cover"]),
                                                   stretchAtTree,
                                                   Sound(fileNames: ["leave_cover"])],
                                         title: "Get to Cover!")
        
        // Take cover at known building
        // TODO directional instruction tech
        // for now, just put a pin on their map
//        let takeCoverAtBuilding = 
        
        // Avoid zombies by taking high route
        // TODO set up altitude data saving
        let monitorAltitude = SensorCollector(lengthInSeconds: 150, dataLabel: "high_point", sensors: [.Location, .Altitude])
        let takeHighRoute = Interaction(moments: [Sound(fileNames: ["radio_static", "high_route_1", "radio_static",]),
                                                  monitorAltitude],
                                        title: "Take High Route")
        
        // Go fast past the zombie hangout
        let monitorSpeed = SensorCollector(lengthInSeconds: 30, dataLabel: "stop_sign", sensors: [.Location, .Speed])
        let passZombieHotspot = Interaction(moments: [Sound(fileNames: ["radio_static", "stopsign_hotspot_1", "radio_static",]),
                                                      monitorSpeed,
                                                      Sound(fileNames: ["radio_static", "stopsign_hotspot_2", "radio_static",])],
                                            title: "Pass Zombie Hotspot")
        
        // Find somewhere to sit and rest
        let monitorStop = SensorCollector(lengthInSeconds: 20, dataLabel: "rest_place", sensors: [.Location, .Speed])
        let findRestPlace = Interaction(moments: [Sound(fileNames: ["radio_static", "find_rest_1", "radio_static",]),
                                                  monitorStop,
                                                  Sound(fileNames: ["radio_static", "find_rest_2", "radio_static",])],
                                        title: "Pass Zombie Hotspot")
        
        let allInteractions = [knockForBuildings, getCoverAtTree, takeHighRoute, passZombieHotspot, findRestPlace]
        
        // Construct the experience based on selected mission
        var stages: [Stage] = []
        switch missionTitle {
        case "M1: Jolly Alpha Five Niner (30-35 min)":
            let stage1 = Stage(moments: [mission1Intro, mission1Part02,
                                        Interim(lengthInSeconds: 3.minutesToSeconds),
                                        Sound(fileNames: ["radio_static", "intel_team_intro", "radio_static"]),
                                        Interim(lengthInSeconds: 3.minutesToSeconds)],
                               title: "Stage One")
            let stage2 = Stage(moments: [mission1Part03, Interim(lengthInSeconds: 10)] + takeHighRoute.moments,
                               title: "Stage Two")
            let stage3 = Stage(moments: [mission1Part04, Interim(lengthInSeconds: 5.minutesToSeconds)], title: "Stage Three")
            let stage4 = Stage(moments: [mission1Part05, Interim(lengthInSeconds: 3.minutesToSeconds)] +
                                        passZombieHotspot.moments +
                                        [Interim(lengthInSeconds: 3.minutesToSeconds)],
                               title: "Stage Four")
            let stage5 = Stage(moments: [mission1Part06, mission2Preview], title: "Stage Five")
            stages = [stage1, stage2, stage3, stage4, stage5]
            

            
            experienceManager = ExperienceManager(title: missionTitle, stages: stages, interactionPool: [interactions])
            break
            

        case "Intel Team Missions 1 (<15min)":
            // Demos all of the interactions
            
            var transitions = [Sound]()
            for var i=0; i < allInteractions.count; i++ {
                transitions.append(Sound(fileNames: ["vignette_transition"]))
            }
            
            let stage1 = Stage(moments: [Sound(fileNames: ["radio_static", "intel_team_intro", "radio_static"])] +
                                        transitions +
                                        [Sound(fileNames: ["radio_static", "intel_missions_end", "radio_static"])],
                                title: "All Interaction Stage",
                                interactionInsertionIndices: [2,3,4,5,6],
                                interactionPool: allInteractions)
            
            
            stages = [stage1]
            
            // Zombie music: https://www.youtube.com/watch?v=vClu9SCxHhI&spfreload=10
            
            experienceManager = ExperienceManager(title: missionTitle, stages: stages)
            
            break
            
        default:
            experienceManager = ExperienceManager(title: missionTitle, stages: stages)
            break
        
        }
        
        
        experienceManager.delegate = self

        // Set up the map view
        mapView.delegate = self
        mapView.mapType = MKMapType.Standard
        mapView.userTrackingMode = MKUserTrackingMode.FollowWithHeading // don't use heading for now, annoying to always calibrate compass + UI unnecessary
        mapView.showsUserLocation = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func back(sender: UIBarButtonItem) {

        if self.experienceManager.currentStageIdx > -1 {
            let refreshAlert = UIAlertController(title: "Are you sure?", message: "This will end the mission. All progress will be lost.", preferredStyle: UIAlertControllerStyle.Alert)
        
            refreshAlert.addAction(UIAlertAction(title: "Exit Mission", style: .Destructive , handler: { (action: UIAlertAction!) in
                self.experienceManager.pause()
                self.navigationController?.popViewControllerAnimated(true)
            }))
        
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
            }))
    
        
            presentViewController(refreshAlert, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
        
    }
    
    
    func addObjectToMap(objectLocation: CLLocationCoordinate2D, annotationTitle: String) {
        // for now, assume it won't be so far away that
        // it isn't on the map (don't worry about changing view region)
        
        if let currentAnnotation = currentAnnotation {
            mapView.removeAnnotation(currentAnnotation)
        }
        
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = objectLocation
        objectAnnotation.title = annotationTitle
        mapView.addAnnotation(objectAnnotation)
        mapView.selectAnnotation(objectAnnotation, animated: false)
        
        currentAnnotation = objectAnnotation
    }
    
    
    // ExperienceManagerDelegate methods
    func didFinishStage() {
        if let currentAnnotation = currentAnnotation {
            mapView.removeAnnotation(currentAnnotation)
        }
    }
    
    func didFinishExperience() {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }
    
    func didAddDestination(destLocation: CLLocationCoordinate2D, destinationName: String) {
        addObjectToMap(destLocation, annotationTitle: destinationName)
    }
    
}

