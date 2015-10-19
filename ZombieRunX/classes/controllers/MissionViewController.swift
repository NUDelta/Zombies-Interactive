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
    
    @IBAction func previousMoment(sender: AnyObject) {
        // FIX this requires too much knowledge of internals for another developer to use
        let currentMoment = self.experienceManager.currentStage?.currentMoment
        (currentMoment as? Sound)?.player?.stop()
        (currentMoment as? Silence)?.player?.stop()
        
        if self.experienceManager.isPlaying == false {
            self.controlLabel.setTitle("Pause", forState: .Normal)
        }
        
        currentMoment?.finished()
    }
    
    @IBAction func nextMoment(sender: AnyObject) {
        // FIX this requires too much knowledge of internals for another developer to use
        let currentMoment = self.experienceManager.currentStage?.currentMoment
        (currentMoment as? Sound)?.player?.stop()
        (currentMoment as? Silence)?.player?.stop()
        
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
        let silence1 = Silence(lengthInSeconds: 5.minutesToSeconds)
        let run_scene = Sound(fileName:"zombie_run2", title: "Run Scene")
        let silence2 = Silence(lengthInSeconds: 5.minutesToSeconds)
        
        //stage 2
        let hospital_scene = Sound(fileName: "zombie_run3", title: "Hospital Scene")
        let silence3 = Silence(lengthInSeconds: 5.minutesToSeconds)
        
        // stage 3
        let knockInstruction = Sound(fileName: "knock_for_building_radio")
        let waitForKnocks = WaitForDoubleKnock(lengthInSeconds: 60)
        
        // stage 4 (final)
        let silence10 = Silence(lengthInSeconds: 10)
        let enterSafety = Sound(fileName:"zombie_run4", title: "Enter Safety")
        
        // experience (Mission)
        let stage1 = Stage(moments: [helicopter_scene, silence1, run_scene, silence2], title: "Stage One")
        let stage2 = Stage(moments: [hospital_scene, silence3], title: "Stage Two")
        let stage3 = Stage(moments: [knockInstruction, waitForKnocks], title: "Stage Three")
        let stage4 = Stage(moments: [silence10, enterSafety], title: "Final Stage")

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

