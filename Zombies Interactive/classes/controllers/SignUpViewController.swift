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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class SignUpLogInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailBox: UITextField!
    @IBOutlet weak var passwordBox: UITextField!
    var user = PFUser()

    override func viewDidLoad(){
        super.viewDidLoad()
        view.backgroundColor = UIColor(red:0.24, green:0.24, blue:0.25, alpha:1)
        
        
        emailBox.returnKeyType = .done
        passwordBox.returnKeyType = .done
        emailBox.delegate = self
        passwordBox.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    @IBAction func loginButton(_ sender: AnyObject) {
        if (self.emailBox.text?.characters.count > 0) && (self.passwordBox.text?.characters.count > 0){
            
            let username = self.emailBox.text!
            let pwd = self.passwordBox.text!
            
            PFUser.logInWithUsername(inBackground: username, password:pwd) {
                (user: PFUser?, error: Error?) -> Void in
                if user != nil {
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.goToHome()
                    })
                    
                } else {
                    if let error = error,
                        let errorString = (error as NSError).userInfo["error"] as? NSString {
                    
                            let alertController = UIAlertController(title: "Login failed", message:
                                errorString.description, preferredStyle: UIAlertControllerStyle.alert)
                    
                            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    
                            self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            
        } else {
            let alertController = UIAlertController(title: "Login failed", message:
                "Missing information", preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
        

    }
    
    
    @IBAction func submitButton(_ sender: AnyObject) {
        
        if (self.emailBox.text?.characters.count > 0) && (self.passwordBox.text?.characters.count > 0){
            //sign up with email and password
            user.email = self.emailBox.text
            user.password = self.passwordBox.text
            user.username = user.email
            
            user.signUpInBackground {
                (succeeded: Bool, error: Error?) -> Void in
                if let error = error {
                    let errorString = (error as NSError).userInfo["error"] as? NSString
                    
                    // Show the errorString somewhere and let the user try again.
                    print("error signing up : " + String(errorString!))
                    
                    let alertController = UIAlertController(title: "Signup failed", message:
                        errorString?.description, preferredStyle: UIAlertControllerStyle.alert)
                    
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                } else {
                    
                    print("successfully signed up!")
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.goToHome()
                    })
                }
            }
        
        } else {
            let alertController = UIAlertController(title: "Signup failed", message:
                "No information entered", preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func goToHome(){
        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "IntroPageViewController") 
        self.present(viewController, animated: true, completion: nil)
        
        //let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        //let navigationController:UINavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        // go to home page
        //let vc = ViewController(nibName: "HomeVC", bundle:nil)
//        let vc:IntroPageViewController = (storyboard!.instantiateViewControllerWithIdentifier("IntroPageViewController") as? IntroPageViewController)!
//        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}
