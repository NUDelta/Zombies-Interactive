//
//  SignUpLogInViewController.swift
//  testZR
//
//  Created by Scott Cambo on 9/8/15.
//  Copyright (c) 2015 Scott Cambo. All rights reserved.
//

import Foundation
import UIKit
import Parse

class SignUpLogInViewController: UIViewController {
    
    @IBOutlet weak var emailBox: UITextField!
    @IBOutlet weak var passwordBox: UITextField!
    var user = PFUser();

    override func viewDidLoad(){
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func submitButton(sender: AnyObject) {
        
        if (self.emailBox.text?.characters.count > 0) && (self.passwordBox.text?.characters.count > 0){
            //sign up with email and password
            user.email = self.emailBox.text;
            user.password = self.passwordBox.text;
            user.username = user.email;
            
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool, error: NSError?) -> Void in
                if let error = error {
                    let errorString = error.userInfo["error"] as? NSString
                    
                    // Show the errorString somewhere and let the user try again.
                    print("error signing up : " + String(errorString!));
                    
                } else {
                    
                    print("successfully signed up!");
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        print("going to Home");
                        self.goToHome();
                    })
                }
            }
        
        } else {
            // display error
            print("error");
        }
    }
    
    func goToHome(){
        print("goToHome() called")
        //let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil);
        //let navigationController:UINavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        // go to home page
        //let vc = ViewController(nibName: "HomeVC", bundle:nil);
        let vc:UIViewController = storyboard!.instantiateViewControllerWithIdentifier("HomeVC") 
        self.navigationController!.pushViewController(vc, animated: true);
    }
}