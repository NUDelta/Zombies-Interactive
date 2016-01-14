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
    
    override func viewDidLoad(){
        super.viewDidLoad()
        view.backgroundColor = UIColor(red:0.24, green:0.24, blue:0.25, alpha:1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    @IBAction func missionsButton(sender: AnyObject) {
        let vc:UIViewController = storyboard!.instantiateViewControllerWithIdentifier("MissionVC")
        if let missionController = vc as? MissionViewController,
        btn = sender as? UIButton,
        missionTitle = btn.titleLabel?.text {
            missionController.missionTitle = missionTitle
            self.navigationController!.pushViewController(missionController, animated: true)
        }
        
    }
}