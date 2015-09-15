//
//  HomeViewController.swift
//  testZR
//
//  Created by Scott Cambo on 9/9/15.
//  Copyright (c) 2015 Scott Cambo. All rights reserved.
//

import Foundation
import UIKit
import Parse

class HomeViewController: UIViewController {
    
    override func viewDidLoad(){
        super.viewDidLoad();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
    }

    @IBAction func historyButton(sender: AnyObject) {
        // go to history view
        println("historyButton() pressed");
    }
    @IBAction func missionsButton(sender: AnyObject) {
        // go to missions view
        //let vc = ViewController(nibName: "MissionVC", bundle:nil);
        let vc:UIViewController = storyboard!.instantiateViewControllerWithIdentifier("MissionVC") as! UIViewController
        self.navigationController!.pushViewController(vc, animated: true);
    }
}