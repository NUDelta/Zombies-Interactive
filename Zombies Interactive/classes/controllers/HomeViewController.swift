//
//  HomeViewController.swift
//  Zombies Interactive
//
//  Created by Scott Cambo on 9/9/15.
//  Copyright (c) 2015 Scott Cambo. All rights reserved.
//

import Foundation
import UIKit
import Parse

class HomeViewController: UIViewController {
    
    
    @IBOutlet weak var missionLabel: UIButton!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        view.backgroundColor = UIColor(red:0.24, green:0.24, blue:0.25, alpha:1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBOutlet weak var musicNotice: UITextView!
    @IBOutlet weak var musicSwitch: UISwitch!
    
    @IBAction func musicSwitched(_ sender: UISwitch) {
        musicNotice.isHidden = !musicSwitch.isOn
    }

    @IBAction func missionsButton(_ sender: AnyObject) {
        let vc:UIViewController = storyboard!.instantiateViewController(withIdentifier: "MissionVC")
        if let missionController = vc as? MissionViewController,
        let btn = sender as? UIButton,
        let missionTitle = btn.titleLabel?.text {
            missionController.missionTitle = missionTitle
            missionController.musicOn = musicSwitch.isOn
            self.navigationController!.pushViewController(missionController, animated: true)
        }
        
    }
}
