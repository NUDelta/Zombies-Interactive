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

class MissionViewController: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var controlLabel: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    var experienceManager:ExperienceManager!
    @IBOutlet weak var nextMomentButton: UIButton!
    
    @IBAction func nextMoment(sender: AnyObject) {
        let currentMoment = self.experienceManager.currentStage?.currentMoment
        (currentMoment as? Sound)?.player?.stop()
        (currentMoment as? Silence)?.player?.stop()
        
        if self.experienceManager.isPlaying == false {
            self.controlLabel.setTitle("Pause", forState: .Normal)
        }
        
        self.experienceManager.currentStage?.nextMoment()
    }
    
    @IBAction func controlButton(sender: AnyObject) {
        if let label = self.controlLabel.titleLabel?.text where label == "Start" {
            print("\nExperience started")
            self.experienceManager.start()
            self.controlLabel.setTitle("Pause", forState: .Normal)
            nextMomentButton.hidden = false
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
        
        view.backgroundColor = UIColor(red:0.24, green:0.24, blue:0.25, alpha:1)
        
        // initialize stages for experience manager <-- will later be done in a separate file most likely

        // More audio files can be found in Zombies, Run! app package under Preload > Document Bundles > missions
        
        //stage 1
        let helicopter_scene = Sound(fileName:"zombie_run1", title: "Helicopter Scene")
        let silence1 = Silence(lengthInSeconds: 5.minutesToSeconds, interruptable:true)
        let run_scene = Sound(fileName:"zombie_run2", title: "Run Scene")
        let silence2 = Silence(lengthInSeconds: 5.minutesToSeconds, interruptable:true)
        
        //stage 2
        let hospital_scene = Sound(fileName: "zombie_run3", title: "Hospital Scene")
        let silence3 = Silence(lengthInSeconds: 5.minutesToSeconds, interruptable:true)
        
        // interactive stage
        let stopAndWait = Sound(fileName:"zombie_run_interactive1", title: "Stop and Wait")
        //let waitAtTree = WaitForWord(wordsToRecognize:["yes"], lengthInSeconds: 30)
        let readyAtTree = Sound(fileName:"zombie_run_interactive2", title: "Ready at Tree")
        
        // stage 4 (final)
        let silence4 = Silence(lengthInSeconds: 4)
        let goFromTree = Sound(fileName:"zombie_run_interactive3", title: "Go From Tree")
        let enterSafety = Sound(fileName:"zombie_run4", interruptable: true, title: "Enter Safety")
        //var sound2 = Sound(file:"test_sweep", interruptable:false)
        
        // experience (Mission)
        let stage1 = Stage(moments: [helicopter_scene, silence1, run_scene, silence2], title: "Stage One")
        let stage2 = Stage(moments: [hospital_scene, silence3], title: "Stage Two")
        let stage3 = Stage(moments: [stopAndWait, readyAtTree], title: "Stage Three")
        let stage4 = Stage(moments: [silence4, goFromTree, enterSafety], title: "Final Stage")

        experienceManager = ExperienceManager(title: "Mission 1: The Beginning", stages: [stage1, stage2, stage3, stage4])
        
        // TEST STAGE
//        let testDataMoment = DataMoment(fileName: "countdown-beep", dataTypes: [.Location])
//        let testStage = Stage(moments: [testDataMoment], title: "Test DataMoment")
//        experienceManager = ExperienceManager(title: "TEST MISSION", stages: [testStage])
        
        
        // Set up the map view
        mapView.delegate = self
        mapView.mapType = MKMapType.Standard
        mapView.userTrackingMode = MKUserTrackingMode.FollowWithHeading
        mapView.showsUserLocation = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

