//
//  ViewController.swift
//  testZR
//
//  Created by Scott Cambo on 8/17/15.
//  Copyright (c) 2015 Scott Cambo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var controlLabel: UIButton!
    
    var stage1:AppStage!;
    var stage2:AppStage!;
    var expMan:ExperienceManager!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //initialize stages for experience manager <-- will later be done in a separate file most likely
        // initialize experience manager with those stages

        
        stage1 = AppStage(sounds: ["test_sweep"]);
        stage2 = AppStage(sounds: ["zombie_run1"]);
        expMan = ExperienceManager(stages:[self.stage1, self.stage2]);
        
        stage1.events.listenTo("finished", action: {
            println("finished");
        });
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func controlButton(sender: AnyObject) {
        println("controlButton() called");
        if (self.controlLabel.titleLabel!.text == "Play"){
            println("Playing...");
            self.expMan.play();
            self.controlLabel.setTitle("Pause", forState: .Normal);
            
        } else {
            self.expMan.pause();
            self.controlLabel.setTitle("Play", forState: .Normal);
        }
    }

}

