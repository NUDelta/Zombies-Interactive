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
        if let currentSound = self.experienceManager.currentStage.currentMoment as? Sound {
            currentSound.player?.stop()
        }
        
        if self.experienceManager.isPlaying == false {
            self.controlLabel.setTitle("Pause", forState: .Normal)
        }
        
        self.experienceManager.currentStage.next()
    }
    
    @IBAction func controlButton(sender: AnyObject) {
        if (self.controlLabel.titleLabel!.text == "Start"){ // first time starting
            print("\nExperience started")
            print("\nStarting stage: " + self.experienceManager.stages[0].title)
            print("  Starting moment: " + self.experienceManager.stages[0].moments[0].title)
            self.experienceManager.play()
            self.controlLabel.setTitle("Pause", forState: .Normal)
            nextMomentButton.hidden = false
        } else if (self.controlLabel.titleLabel!.text == "Resume"){ // playing after pause
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

        //stage 1
        let helicopter_scene = Sound(fileName:"zombie_run1")
        let silence1 = Silence(lengthInSeconds: 5.minutesToSeconds, interruptable:true)
        let run_scene = Sound(fileName:"zombie_run2")
        let silence2 = Silence(lengthInSeconds: 5.minutesToSeconds, interruptable:true)
        
        //stage 2
        let hospital_scene = Sound(fileName: "zombie_run3")
        let silence3 = Silence(lengthInSeconds: 5.minutesToSeconds, interruptable:true)
        
        // interactive stage
        let stopAndWait = Sound(fileName:"zombie_run_interactive1")
        let waitAtTree = WaitForWord(wordsToRecognize:["yes"], lengthInSeconds: 30)
        let readyAtTree = Sound(fileName:"zombie_run_interactive2")
        
        // stage 4 (final)
        let silence4 = Silence(lengthInSeconds: 4)
        let goFromTree = Sound(fileName:"zombie_run_interactive3")
        let enterSafety = Sound(fileName:"zombie_run4", interruptable: true)
        //var sound2 = Sound(file:"test_sweep", interruptable:false)
        
        // experience (Mission)
        let stage1 = Stage(moments: [helicopter_scene, silence1, run_scene, silence2], title: "Stage One")
        let stage2 = Stage(moments: [hospital_scene, silence3], title: "Stage Two")
        let stage3 = Stage(moments: [stopAndWait, waitAtTree, readyAtTree], title: "Stage Three")
        let stage4 = Stage(moments: [silence4, goFromTree, enterSafety], title: "Final Stage")
        experienceManager = ExperienceManager(title: "Mission 1: The Beginning", stages: [stage1, stage2, stage3, stage4])
        
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

