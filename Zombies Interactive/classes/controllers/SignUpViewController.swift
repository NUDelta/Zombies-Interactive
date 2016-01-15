//
//  SignUpLogInViewController.swift
//  Zombies Interactive
//
//  Created by Scott Cambo on 9/8/15.
//  Copyright (c) 2015 Scott Cambo. All rights reserved.
//

import Foundation
import UIKit
import Parse

class SignUpLogInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailBox: UITextField!
    @IBOutlet weak var passwordBox: UITextField!
    var user = PFUser()

    override func viewDidLoad(){
        super.viewDidLoad()
        view.backgroundColor = UIColor(red:0.24, green:0.24, blue:0.25, alpha:1)
        
        
        emailBox.returnKeyType = .Done
        passwordBox.returnKeyType = .Done
        emailBox.delegate = self
        passwordBox.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    @IBAction func loginButton(sender: AnyObject) {
        if (self.emailBox.text?.characters.count > 0) && (self.passwordBox.text?.characters.count > 0){
            
            let email = self.emailBox.text!
            let pwd = self.passwordBox.text!
            
            PFUser.logInWithUsernameInBackground(email, password:pwd) {
                (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.goToHome()
                    })
                    
                } else {
                    if let error = error,
                        errorString = error.userInfo["error"] as? NSString {
                    
                            let alertController = UIAlertController(title: "Login failed", message:
                                errorString.description, preferredStyle: UIAlertControllerStyle.Alert)
                    
                            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    
                            self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            }
            
        } else {
            let alertController = UIAlertController(title: "Login failed", message:
                "Missing information", preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        

    }
    
    
    @IBAction func submitButton(sender: AnyObject) {
        
        if (self.emailBox.text?.characters.count > 0) && (self.passwordBox.text?.characters.count > 0){
            //sign up with email and password
            user.email = self.emailBox.text
            user.password = self.passwordBox.text
            user.username = user.email
            
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool, error: NSError?) -> Void in
                if let error = error {
                    let errorString = error.userInfo["error"] as? NSString
                    
                    // Show the errorString somewhere and let the user try again.
                    print("error signing up : " + String(errorString!))
                    
                    let alertController = UIAlertController(title: "Signup failed", message:
                        errorString?.description, preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                } else {
                    
                    print("successfully signed up!")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.goToHome()
                    })
                }
            }
        
        } else {
            let alertController = UIAlertController(title: "Signup failed", message:
                "No information entered", preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func goToHome(){
        //let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        //let navigationController:UINavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        // go to home page
        //let vc = ViewController(nibName: "HomeVC", bundle:nil)
        let vc:UIViewController = storyboard!.instantiateViewControllerWithIdentifier("HomeVC") 
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}