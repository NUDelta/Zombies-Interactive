//
//  ViewController.swift
//  ZombieRunX
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

    var experienceManager:ExperienceManager!
    var musicPlayer:MPMusicPlayerController?
    
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
        CLLocationManager().requestAlwaysAuthorization()
        
        view.backgroundColor = UIColor(red:0.24, green:0.24, blue:0.25, alpha:1)
        
        // initialize stages for experience manager <-- will later be done in a separate file most likely - Scott
        
        let mission1Intro = Sound(fileNames: ["ZRS1M1v2"])
        let mission1Part02 = Sound(fileNames: ["M-E01-02"])
        let mission1Part03 = Sound(fileNames: ["M-E01-03"])
        let mission1Part04 = Sound(fileNames: ["M-E01-04"])
        let mission1Part05 = Sound(fileNames: ["M-E01-05"])
        let mission1Part06 = Sound(fileNames: ["M-E01-06"])
        let mission2Preview = Sound(fileNames: ["NextTimeS1M3"])
        
        
        // interactions
        
        // Identify vantage points
        let identifyBuildings = KnockListener(title: "Identify Vantage Points",
                                            lengthInSeconds: 6.minutesToSeconds,
                                            dataLabel: "tall_building",
                                            recordMultiple: true,
                                            requireDoubleKnock: true)
        let knockForBuildings = Interaction(moments: [Sound(fileNames: ["radio_static", "knock_for_building", "radio_static"]),
                                                      identifyBuildings,
                                                      Sound(fileNames: ["radio_static", "evaluating_vantage_points", "radio_static"])],
                                            title: "Identify Vantage Points")
        
        // Find tree cover and stretch
        let stretchAtTree = SensorCollector(lengthInSeconds: 90, title: "Get Cover and Stretch", dataLabel: "tree", sensors: [.Location])
        let getCoverAtTree = Interaction(moments: [Sound(fileNames: ["find_cover"]),
                                                   stretchAtTree,
                                                   Sound(fileNames: ["leave_cover"])],
                                         title: "Cover At Tree")
        
        // Take cover at known building
        // TODO directional instruction tech
        
        // Avoid zombies by taking high route
        // TODO set up altitude data saving
        let monitorAltitude = SensorCollector(lengthInSeconds: 60, dataLabel: "hill", sensors: [.Location, .Altitude])
        let takeHighRoute = Interaction(moments: [Sound(fileNames: ["radio_static", "high_route_1", "radio_static",]),
                                                  monitorAltitude],
                                        title: "Take High Route")
        
        // Go fast past the zombie hangout
        let monitorSpeed = SensorCollector(lengthInSeconds: 20, dataLabel: "stop_sign", sensors: [.Location, .Speed])
        let passZombieHotspot = Interaction(moments: [Sound(fileNames: ["radio_static", "stopsign_hotspot_1", "radio_static",]),
                                                      monitorSpeed,
                                                      Sound(fileNames: ["radio_static", "stopsign_hotspot_2", "radio_static",])],
                                            title: "Pass Zombie Hotspot")
        
        // Find somewhere to sit and rest
        let monitorStop = SensorCollector(lengthInSeconds: 20, dataLabel: "rest_place", sensors: [.Location, .Speed])
        let findRestPlace = Interaction(moments: [Sound(fileNames: ["radio_static", "stopsign_hotspot_1", "radio_static",]),
                                                  monitorStop,
                                                  Sound(fileNames: ["radio_static", "stopsign_hotspot_2", "radio_static",])],
                                        title: "Pass Zombie Hotspot")
        
        
        let stage1 = Stage(moments: [mission1Intro, mission1Part02, Interim(lengthInSeconds: 6.minutesToSeconds)], title: "Stage One")
        let stage2 = Stage(moments: [mission1Part03, Interim(lengthInSeconds: 10)] + knockForBuildings.moments, title: "Stage Two")
        let stage3 = Stage(moments: [mission1Part04, Interim(lengthInSeconds: 6.minutesToSeconds)], title: "Stage Three")
        let stage4 = Stage(moments: [mission1Part05, Interim(lengthInSeconds: 3.minutesToSeconds)] +
                                    getCoverAtTree.moments +
                                    [Interim(lengthInSeconds: 3.minutesToSeconds)], title: "Stage Four")
        let stage5 = Stage(moments: [mission1Part06, mission2Preview], title: "Stage Five")

        experienceManager = ExperienceManager(title: "S1M1: Jolly Alpha Five Niner", stages: [stage1, stage2, stage3, stage4, stage5])
        

        
        
        // RANDOM INTERACTION DEMO
        
//        let doABackflip = Interaction(moments: [Sound(fileNames: ["do_a_backflip"])], title: "Do A Backflip!")
//        let yellTheFWord = Interaction(moments: [Sound(fileNames: ["yell_the_fword"])], title: "Yell the F Word")
//        

//        let testStage = Stage(
//            moments: [Interim(lengthInSeconds: 10), mission1Intro, Interim(lengthInSeconds: 10)],
//            title: "Random Interaction Stage",
//            interactionInsertionIndices: [1,3],
//            interactionPool: [getCoverAtTree, knockForBuildings, doABackflip, yellTheFWord])
//        
//        experienceManager = ExperienceManager(title: "Sprint 3 Demo", stages: [testStage])
        
        
        // OPPORTUNITY QUEUE DEMO
//        let chickenShackLocation = CLLocationCoordinate2D(latitude: 42.052860617171845, longitude: -87.68747791910707)
//        let chickenShackRegion = CLCircularRegion(center: chickenShackLocation, radius: 2000, identifier: "Chicken Shack")
//        
//        let testStage = Stage(
//            moments: [Interim(isInterruptable: true, lengthInSeconds: 80), mission1Intro],
//            title: "Opportunity Queue Stage")
//
//        experienceManager = ExperienceManager(
//            title: "Sprint 3 Demo",
//            stages: [testStage],
//            regionBasedInteractions: [chickenShackRegion : getCoverAtTree])
        
        
        experienceManager.delegate = self

        // Set up the map view
        mapView.delegate = self
        mapView.mapType = MKMapType.Standard
        mapView.userTrackingMode = MKUserTrackingMode.Follow // don't use heading for now, annoying to always calibrate compass + UI unnecessary
        mapView.showsUserLocation = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // ExperienceManagerDelegate methods
    func didFinishExperience() {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }

}

