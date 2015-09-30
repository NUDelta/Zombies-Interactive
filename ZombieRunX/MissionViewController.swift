//
//  ViewController.swift
//  testZR
//
//  Created by Scott Cambo on 8/17/15.
//  Copyright (c) 2015 Scott Cambo. All rights reserved.
//

import UIKit
import Parse
import MapKit

class MissionViewController: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var controlLabel: UIButton!
    @IBOutlet weak var theMap: MKMapView!
    var expMan:ExperienceManager!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /* Parse test -- Remove when done */
        
        //initialize stages for experience manager <-- will later be done in a separate file most likely
        // initialize experience manager with those stages

        //stage 1
        let helicopter_scene = Sound(file:"zombie_run1", interruptable:false)
        let silence1 = Silence(length:300.0, interruptable:true); // 5 minutes of silence (5 * 60 = 300)
        let run_scene = Sound(file:"zombie_run2", interruptable: false);
        let silence2 = Silence(length:300.0, interruptable:true); // length is seconds
        
        //stage 2
        let hospital_scene = Sound(file: "zombie_run3", interruptable: false);
        let silence3 = Silence(length:300.0, interruptable:true);
        
        // interactive stage
        let stopAndWait = Sound(file:"zombie_run_interactive1", interruptable: false);
        let waitAtTree = waitForYes(length:30.0, interruptable:false);
        let readyAtTree = Sound(file:"zombie_run_interactive2", interruptable: false);
        
        // stage 4 (final
        let silence4 = Silence(length:4.0, interruptable: false);
        let goFromTree = Sound(file:"zombie_run_interactive3", interruptable: false);
        let enterSafety = Sound(file:"zombie_run4", interruptable: true);
        //var sound2 = Sound(file:"test_sweep", interruptable:false);
        
        //experience (Mission)
        let stage1 = AppStage(moments: [helicopter_scene, silence1, run_scene, silence2]);
        let stage2 = AppStage(moments: [hospital_scene, silence3]);
        let stage3 = AppStage(moments: [stopAndWait, waitAtTree, readyAtTree, silence4, goFromTree]);
        let stage4 = AppStage(moments: [enterSafety]);
        expMan = ExperienceManager(experience_title: "Mission 1: The Beginning", stages: [stage1, stage2, stage3, stage4]);
        
        // Set up the map view
        theMap.delegate = self
        theMap.mapType = MKMapType.Standard
        theMap.showsUserLocation = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func controlButton(sender: AnyObject) {
        print("controlButton() called");
        if (self.controlLabel.titleLabel!.text == "Start"){ // first time starting
            
        } else if (self.controlLabel.titleLabel!.text == "Play"){ // playing after pause
            print("Playing...");
            self.expMan.play();
            self.controlLabel.setTitle("Pause", forState: .Normal);
            
        } else { // pause while playing after started
            self.expMan.pause();
            self.controlLabel.setTitle("Play", forState: .Normal);
        }
    }

}

