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
            print("\nExperience started")
            self.experienceManager.start()
            self.controlLabel.setTitle("Pause", forState: .Normal)
            //#if DEBUG
            nextMomentButton.hidden = false
            //#endif
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
        
        // 11m23s of audio
        let mission1Intro = Sound(fileName: "ZRS1M1v2")
        let mission1Part02 = Sound(fileName: "M-E01-02")
        let mission1Part03 = Sound(fileName: "M-E01-03")
        
        // this is an interaction -- an array of moments?
        // but it should have a title as well to know if it's been used
        // could make it its own class to simplify for usage
        // but you still need to know how to add it to a stage with concatenation
        let static1 = Sound(fileName: "radio_static")
        let knockForBuildingsInstruction = Sound(fileName: "knock_for_building")
        let static2 = Sound(fileName: "radio_static")
        let identifyBuildings = WaitForDoubleKnock(lengthInSeconds: 6.minutesToSeconds, title: "Identify Vantage Points", dataLabel: "tall_building")
        let static3 = Sound(fileName: "radio_static")
        let sendingScouts = Sound(fileName: "evaluating_vantage_points")
        let static4 = Sound(fileName: "radio_static")
        let knockForVantagePointsInteraction = Interaction(moments: [static1, knockForBuildingsInstruction, static2,
            identifyBuildings, static3, sendingScouts, static4], title: "knockForVantagePointsInteraction")
        
        let mission1Part04 = Sound(fileName: "M-E01-04")
        let mission1Part05 = Sound(fileName: "M-E01-05")
        
        // interaction
        let stopAtTree = Sound(fileName: "find_cover")
        let stretchAtTree = DataMoment(lengthInSeconds: 90, title: "Get Cover and Stretch", dataLabel: "tree", dataTypes: [.Location])
        let leaveCover = Sound(fileName: "leave_cover")
        let getCoverAtTreeInteraction = Interaction(moments: [stopAtTree, stretchAtTree, leaveCover], title: "getCoverAtTreeInteraction")
        
        let mission1Part06 = Sound(fileName: "M-E01-06")
        let mission2Preview = Sound(fileName: "NextTimeS1M3")
        
        let stage1 = Stage(moments: [mission1Intro, mission1Part02, Silence(lengthInSeconds: 6.minutesToSeconds)], title: "Stage One")
        let stage2 = Stage(moments: [mission1Part03, Silence(lengthInSeconds: 10)] + knockForVantagePointsInteraction.moments, title: "Stage Two")
        let stage3 = Stage(moments: [mission1Part04, Silence(lengthInSeconds: 6.minutesToSeconds)], title: "Stage Three")
        let stage4 = Stage(moments: [mission1Part05, Silence(lengthInSeconds: 3.minutesToSeconds)] +
                                    getCoverAtTreeInteraction.moments +
                                    [Silence(lengthInSeconds: 3.minutesToSeconds)], title: "Stage Four")
        let stage5 = Stage(moments: [mission1Part06, mission2Preview], title: "Stage Five")

        experienceManager = ExperienceManager(title: "S1M1: Jolly Alpha Five Niner", stages: [stage1, stage2, stage3, stage4, stage5])
        
        // example of adding interactions chosen randomly into a designated part of the stage
//        let stage1 = Stage(moments: [mission1Intro], title: "test", interactionInsertionIndices: [0,1], interactionPool: [knockForVantagePointsInteraction, getCoverAtTreeInteraction])
//        experienceManager = ExperienceManager(title: "Testing Randomized Interactions", stages: [stage1])
        
        
        experienceManager.delegate = self

        // Set up the map view
        mapView.delegate = self
        mapView.mapType = MKMapType.Standard
        mapView.userTrackingMode = MKUserTrackingMode.Follow // don't use heading for now, annoying to always calibrate compass
        mapView.showsUserLocation = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func didFinishExperience() {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }

}
