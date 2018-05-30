//
//  ViewController.swift
//  Zombies Interactive
//
//  Created by Scott Cambo on 8/17/15.
//  Copyright (c) 2015 Scott Cambo. All rights reserved.
//

import UIKit
import Parse
import MapKit
import MediaPlayer
import CoreLocation
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
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

class MissionViewController: UIViewController, MKMapViewDelegate, ExperienceManagerDelegate {

    var missionTitle: String = ""
    var musicOn: Bool = true
    var experienceManager:ExperienceManager!
    var musicPlayer:MPMusicPlayerController?
    var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    var currentAnnotation: MKAnnotation?
    
    var currentMomentIsInterim: Bool = false
    
    let pedometer = CMPedometer()
    var startDate: Date!
    var missionComplete: Bool = false
    
    @IBOutlet weak var controlLabel: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nextMomentButton: UIButton!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var stepsTakenLabel: UILabel!
    @IBOutlet weak var endExperience: UIButton!
    
    @IBAction func endExperience(_ sender: AnyObject) {
        self.experienceManager.finishExperience()
    }
    
    @IBAction func previousMoment(_ sender: AnyObject) {
        // FIX this requires too much knowledge of internals for another developer to use
        let currentMoment = self.experienceManager.currentMomentBlock?.currentMoment
        (currentMoment as? Sound)?.player?.stop()
        
        if self.experienceManager.isPlaying == false {
            self.controlLabel.setTitle("Pause", for: UIControlState())
        }
        
        currentMoment?.finished()
    }
    
    @IBAction func nextMoment(_ sender: AnyObject) {
        // FIX this requires too much knowledge of internals for another developer to use
        let currentMoment = self.experienceManager.currentMomentBlock?.currentMoment
        (currentMoment as? Sound)?.player?.stop()
        
        if self.experienceManager.isPlaying == false {
            self.controlLabel.setTitle("Pause", for: UIControlState())
        }

        currentMoment?.finished()
    }
    
    @IBAction func controlButton(_ sender: AnyObject) {
        if let label = self.controlLabel.titleLabel?.text, label == "Start" {
            self.experienceManager.start()
            self.controlLabel.setTitle("Pause", for: UIControlState())
            #if DEBUG
            nextMomentButton.isHidden = false
            #endif
            startDate = Date()
            let _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MissionViewController.updateTimeElapsed), userInfo: nil, repeats: true)
            
            if(CMPedometer.isStepCountingAvailable()){
                pedometer.startUpdates(from: startDate) {
                    (data: CMPedometerData?, error) -> Void in
                    DispatchQueue.main.async(execute: { () -> Void in
                        if(error == nil){
                            if let distance = data?.distance {
                                self.stepsTakenLabel.text = String(format: "Estimated %.2f miles traveled", distance.toMiles)
                            }
                        }
                    })   
                }
            }

            
        } else if self.controlLabel.titleLabel!.text == "Resume" {
            print("  Experience resumed")
            self.experienceManager.play()
            if musicOn && currentMomentIsInterim {
                playMusic()
            }
            self.controlLabel.setTitle("Pause", for: UIControlState())
        } else if self.controlLabel.titleLabel!.text == "Pause" {
            print("  Experience paused")
            self.experienceManager.pause()
            if audioSession.isOtherAudioPlaying {
                pauseMusic()
            }
            self.controlLabel.setTitle("Resume", for: UIControlState())
       
        }
    }
    
    func secondsToHoursMinutesSeconds (_ seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func updateTimeElapsed() {
        let (h,m,s) = secondsToHoursMinutesSeconds(Int(Date().timeIntervalSince(startDate)))
        timeElapsedLabel.text = "\(h)h \(m)m \(s)s elapsed"
        
    }
    
    @IBAction func btn_startLocUpdate(_ sender: AnyObject) {
        self.experienceManager.dataManager?.startUpdatingLocation()
    }
    @IBAction func btn_pushLampT(_ sender: AnyObject) {
        print("push:lampT")
        self.experienceManager.dataManager?.pushWorldObject(["label": "lamp", "interaction" : "find_lamp", "variation" : "0"])
    }
    @IBAction func btn_pushLampF(_ sender: AnyObject) {
        print("push:lampF")
        self.experienceManager.dataManager?.pushWorldObject(["label": "lamp(false)", "interaction" : "find_lamp", "variation" : "0"])
    }
    @IBAction func btn_pushLampValid(_ sender: AnyObject) {
        print("push:lampValid")
    }
    @IBAction func btn_pushLampInvalid(_ sender: AnyObject) {
        print("push:lampInvalid")
    }
    @IBAction func btn_pushLampPost(_ sender: AnyObject) {
        print("push:lampPostT")
        self.experienceManager.dataManager?.pushWorldObject(["label": "lamp_poster", "interaction" : "scaffold_lamp_posters", "variation" : "1"])
    }
    @IBAction func btn_pushLampPostF(_ sender: AnyObject) {
        print("push:lampPostF")
        self.experienceManager.dataManager?.pushWorldObject(["label": "lamp_poster(false)", "interaction" : "scaffold_lamp_posters", "variation" : "1"])
    }
    
//    func initializeExperienceManager() -> String{
//        var moment = [String:Any]()
//        CommManager.instance.getRequest(route: "intro", parameters: [:]) {
//            json in
//            print (json)
//            moment = json
//            let block_body = MomentBlock(moments: [Sound(fileNames: ["radio_static"]),
//                                                         SynthVoiceMoment(content: moment["prompt"] as! String),
//                                                         Sound(fileNames: ["radio_static", "vignette_transition"])], title: "block:body")
//            // Insert intro into experience manager start
////            let stages: [MomentBlock] = [block_body]
////            self.experienceManager = ExperienceManager(title: self.missionTitle,  momentBlocks: stages)
//            //self.experienceManager.delegate = self
//            //self.experienceManager.insertMomentBlockSimple(block_body)
//        }
//        return "Success"
//    }
    
//    func getEndMoment() -> String{
//        var moment = [String:Any]()
//        CommManager.instance.getRequest(route: "end", parameters: [:]) {
//            json in
//            print (json)
//            moment = json
//            let block_body = MomentBlockSimple(moments: [Sound(fileNames: ["radio_static"]),
//                                                         SynthVoiceMoment(content: moment["prompt"] as! String),
//                                                         Sound(fileNames: ["radio_static", "vignette_transition"])], title: "block:body")
//            // Insert end into experience manager where??
//            // self.experienceManager.insertMomentBlockSimple(block_body)
//        }
//        return "Success"
//    }
    
// Set up run document on backend
    func initialize_run(){
        var initialization_json = [String:String]();
        let todaysDate:Date = Date()
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let DateInFormat:String = dateFormatter.string(from: todaysDate)
        
        // Could send more attributes here to front end for run initialization later on
        initialization_json["start_time"] = DateInFormat
        var ret = [String:Any]()
        CommManager.instance.urlRequest(route: "initialize_run", parameters: initialization_json, completion: {
            json in
            ret = json
            // Receive the run_id and user_id and save it in the Experience Manager object
            print(self.experienceManager.run_id)
            self.experienceManager.run_id = ret["run_id"] as! String
            print(self.experienceManager.run_id)
            self.experienceManager.user_id = ret["user_id"] as! String
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(MissionViewController.back(_:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        view.backgroundColor = UIColor(red:0.24, green:0.24, blue:0.25, alpha:1)
        
        /*
        *
        * MARK: HARDCODED EXPERIENCE -> DYNAMIC EXPERIENCE
        *   
        */
        
        // Initialize experience manager with intro moment grabbed from backend
        let intro_text = "Hey there, runner number 5. I am your guide. We need you to get back to base safely and gather some important information for us about the Northwestern Campus. Got it? Ok. Keep a good pace and stay alert"
        
        let newIntroMoment:Moment = SynthVoiceMoment(title:"intro", isInterruptable: false, content: intro_text)

        let block_body = MomentBlock(moments: [newIntroMoment], title: "block:body")
        
//        let block_body = MomentBlock(moments: [Sound(fileNames:["radio_static"], isInterruptable: false),newIntroMoment], title: "block:body")
       
        let block_body2 = MomentBlock(moments: [Sound(fileNames: ["silence"], isInterruptable:true)],  title: "block:silence")
//
//        let block_body3 = MomentBlock(moments: [Sound(fileNames: ["silence"], isInterruptable:true)],  title: "block:silence2")
        
        let stages: [MomentBlock] = [block_body, block_body2]
        // NEW EXPERIENCE MANAGER:
        experienceManager = ExperienceManager(title: "Mission title", momentBlocks: stages)
        // Call initialize run to record run
        initialize_run()
        
        // Set up the map view
        mapView.delegate = self
        mapView.mapType = MKMapType.standard
        mapView.userTrackingMode = MKUserTrackingMode.follow // don't use heading for now, annoying to always calibrate compass + UI unnecessary
        mapView.showsUserLocation = true

        do {
            try self.audioSession.setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
            try self.audioSession.setActive(false, with: .notifyOthersOnDeactivation)
            } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func back(_ sender: UIBarButtonItem) {

        if self.experienceManager.currentMomentBlockIdx > -1 && missionComplete == false {
            
            let refreshAlert = UIAlertController(title: "Are you sure?", message: "This will end the mission. All progress will be lost.", preferredStyle: UIAlertControllerStyle.alert)
        
            refreshAlert.addAction(UIAlertAction(title: "Exit Mission", style: .destructive , handler: { (action: UIAlertAction!) in
                self.experienceManager.pause()
                self.navigationController?.popViewController(animated: true)
            }))
        
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
            }))
    
        
            present(refreshAlert, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    
    func addObjectToMap(_ objectLocation: CLLocationCoordinate2D, annotationTitle: String) {
        // for now, assume it won't be so far away that
        // it isn't on the map (don't worry about changing view region)
        
        if let currentAnnotation = currentAnnotation {
            mapView.removeAnnotation(currentAnnotation)
        }
        
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = objectLocation
        objectAnnotation.title = annotationTitle
        mapView.addAnnotation(objectAnnotation)
        mapView.selectAnnotation(objectAnnotation, animated: false)
        
        currentAnnotation = objectAnnotation
    }
    
    
    // ExperienceManagerDelegate methods
    
    func didFinishStage() {
        if let currentAnnotation = currentAnnotation {
            mapView.removeAnnotation(currentAnnotation)
        }
    }
    
    func didFinishExperience() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, with: .notifyOthersOnDeactivation)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        let systemPlayer = MPMusicPlayerController.systemMusicPlayer()
        if let _ = systemPlayer.nowPlayingItem {
            systemPlayer.play()
        }
        
        controlLabel.setTitle("Mission Complete", for: UIControlState())
        missionComplete = true
        
//        if let navController = self.navigationController {
//            navController.popViewControllerAnimated(true)
//        }
    }
    
    func pauseMusic() {
        // TODO fade out?
        MPMusicPlayerController.systemMusicPlayer().pause()
    }
    
    func playMusic() {
        // TODO fade in?
        MPMusicPlayerController.systemMusicPlayer().play()
    }
    
    func didAddDestination(_ destLocation: CLLocationCoordinate2D, destinationName: String) {
        addObjectToMap(destLocation, annotationTitle: destinationName)
    }
    
    
    func didBeginInterim() {
        currentMomentIsInterim = true
        // don't try to play the system player if it's in simulator
        #if (arch(i386) || arch(x86_64)) && os(iOS)
        #else
            if musicOn {
                playMusic()
            }
        #endif
    }
    
    func didBeginSound() {
        currentMomentIsInterim = false
        if musicOn && audioSession.isOtherAudioPlaying {
            pauseMusic()
        }
    }
}

