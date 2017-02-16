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


class MissionViewController: UIViewController, MKMapViewDelegate, ExperienceManagerDelegate {

    var missionTitle: String = ""
    var musicOn: Bool = false
    var experienceManager:ExperienceManager!
    var musicPlayer:MPMusicPlayerController?
    var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    var currentAnnotation: MKAnnotation?
    
    var currentMomentIsInterim: Bool = false
    
    let pedometer = CMPedometer()
    var startDate: NSDate!
    var missionComplete: Bool = false
    
    @IBOutlet weak var controlLabel: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nextMomentButton: UIButton!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var stepsTakenLabel: UILabel!
    
    @IBAction func previousMoment(sender: AnyObject) {
        // FIX this requires too much knowledge of internals for another developer to use
        let currentMoment = self.experienceManager.currentMomentBlock?.currentMoment
        (currentMoment as? Sound)?.player?.stop()
        
        if self.experienceManager.isPlaying == false {
            self.controlLabel.setTitle("Pause", forState: .Normal)
        }
        
        currentMoment?.finished()
    }
    
    @IBAction func nextMoment(sender: AnyObject) {
        // FIX this requires too much knowledge of internals for another developer to use
        let currentMoment = self.experienceManager.currentMomentBlock?.currentMoment
        (currentMoment as? Sound)?.player?.stop()
        
        if self.experienceManager.isPlaying == false {
            self.controlLabel.setTitle("Pause", forState: .Normal)
        }

        currentMoment?.finished()
    }
    
    @IBAction func controlButton(sender: AnyObject) {
        if let label = self.controlLabel.titleLabel?.text where label == "Start" {
            self.experienceManager.start()
            self.controlLabel.setTitle("Pause", forState: .Normal)
            #if DEBUG
//            nextMomentButton.hidden = false
            #endif
            startDate = NSDate()
            let _ = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(MissionViewController.updateTimeElapsed), userInfo: nil, repeats: true)
            
            if(CMPedometer.isStepCountingAvailable()){
                pedometer.startPedometerUpdatesFromDate(startDate) {
                    (data: CMPedometerData?, error) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
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
            self.controlLabel.setTitle("Pause", forState: .Normal)
        } else if self.controlLabel.titleLabel!.text == "Pause" {
            print("  Experience paused")
            self.experienceManager.pause()
            if audioSession.otherAudioPlaying {
                pauseMusic()
            }
            self.controlLabel.setTitle("Resume", forState: .Normal)
        }
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func updateTimeElapsed() {
        let (h,m,s) = secondsToHoursMinutesSeconds(Int(NSDate().timeIntervalSinceDate(startDate)))
        timeElapsedLabel.text = "\(h)h \(m)m \(s)s elapsed"
        
    }
    
    @IBAction func btn_startLocUpdate(sender: AnyObject) {
        self.experienceManager.dataManager?.startUpdatingLocation()
    }
    @IBAction func btn_pushLampT(sender: AnyObject) {
        print("push:lampT")
        self.experienceManager.dataManager?.pushWorldObject(["label": "lamp", "interaction" : "find_lamp", "variation" : "0"])
    }
    @IBAction func btn_pushLampF(sender: AnyObject) {
        print("push:lampF")
        self.experienceManager.dataManager?.pushWorldObject(["label": "lamp(false)", "interaction" : "find_lamp", "variation" : "0"])
    }
    @IBAction func btn_pushLampValid(sender: AnyObject) {
        print("push:lampValid")
    }
    @IBAction func btn_pushLampInvalid(sender: AnyObject) {
        print("push:lampInvalid")
    }
    @IBAction func btn_pushLampPost(sender: AnyObject) {
        print("push:lampPostT")
        self.experienceManager.dataManager?.pushWorldObject(["label": "lamp_poster", "interaction" : "scaffold_lamp_posters", "variation" : "1"])
    }
    @IBAction func btn_pushLampPostF(sender: AnyObject) {
        print("push:lampPostF")
        self.experienceManager.dataManager?.pushWorldObject(["label": "lamp_poster(false)", "interaction" : "scaffold_lamp_posters", "variation" : "1"])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(MissionViewController.back(_:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        view.backgroundColor = UIColor(red:0.24, green:0.24, blue:0.25, alpha:1)
        
        // we don't need it now, but this line prompts the user to give permissions
        // so it doesn't come up later on when the phone is in their pocket
        CMMotionActivityManager().stopActivityUpdates()
        CLLocationManager().requestAlwaysAuthorization()
        
        /*
        *
        * MARK: Sprinting interactions
        *   
        */
        print("[MissionViewController] init experiences")
        
        
        let intelIntro = MomentBlockSimple(moments: [Sound(fileNames: ["radio_static"]), SynthVoiceMoment(content: "Runner 5, this is the advanced intel team at Abel Township. Our job is to learn as much as possible about what’s out there beyond the colony. You’re the only runner whose device is still fully functioning, so we’re going to have to ask you to do some reconnaissance work. Good luck."), Sound(fileNames: ["radio_static"])], title: "Intel intro")
        
        let findHydrantInstruct = MomentBlockSimple(moments: [Sound(fileNames: ["radio_static"]), SynthVoiceMoment(content: "Runner 5, our monitors show your pace has slowed and zombies in the area are gaining ground. You need to increase speed to reach a safe distance. You should pass a fire hydrant after a few seconds, at which point you should return to regular pace. Begin sprinting now."), Sound(fileNames: ["radio_static"])], title: "Fire hydrant instruct")
        
        let findHydrantComplete = MomentBlockSimple(moments: [Sound(fileNames: ["radio_static"]), SynthVoiceMoment(content: "You’ve thrown off the scent and bought yourself some time... That will be all for now. Nice work."), Sound(fileNames: ["radio_static"])], title: "Fire hydrant complete")
        
        
        let findHydrantCollector = Interim(lengthInSeconds: 8)
        
        
        // Construct the experience based on selected mission
        var stages: [MomentBlock] = []
        if missionTitle == "UIST Intel Mission" {
            let stage1 = MomentBlock(moments: intelIntro.moments + [Sound(fileNames: ["vignette_transition"])], title: "Stage1")
            let stage2 = MomentBlock(moments: findHydrantInstruct.moments + [findHydrantCollector] + findHydrantComplete.moments + [Sound(fileNames: ["vignette_transition"])], title: "Stage2")
            
            stages = [stage1, stage2]
        }
        
        experienceManager = ExperienceManager(title: missionTitle, momentBlocks: stages)
        //SET DELEGATES
        experienceManager.delegate = self

        // Set up the map view
        mapView.delegate = self
        mapView.mapType = MKMapType.Standard
        mapView.userTrackingMode = MKUserTrackingMode.Follow // don't use heading for now, annoying to always calibrate compass + UI unnecessary
        mapView.showsUserLocation = true
        

        do {
            try self.audioSession.setCategory(AVAudioSessionCategoryPlayback, withOptions: .MixWithOthers)
            try self.audioSession.setActive(false, withOptions: .NotifyOthersOnDeactivation)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func back(sender: UIBarButtonItem) {

        if self.experienceManager.currentMomentBlockIdx > -1 && missionComplete == false {
            
            let refreshAlert = UIAlertController(title: "Are you sure?", message: "This will end the mission. All progress will be lost.", preferredStyle: UIAlertControllerStyle.Alert)
        
            refreshAlert.addAction(UIAlertAction(title: "Exit Mission", style: .Destructive , handler: { (action: UIAlertAction!) in
                self.experienceManager.pause()
                self.navigationController?.popViewControllerAnimated(true)
            }))
        
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
            }))
    
        
            presentViewController(refreshAlert, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
        
    }
    
    
    func addObjectToMap(objectLocation: CLLocationCoordinate2D, annotationTitle: String) {
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
//        do {
//            try AVAudioSession.sharedInstance().setActive(false, withOptions: .NotifyOthersOnDeactivation)
//        } catch let error as NSError {
//            print(error.localizedDescription)
//        }
//
//        let systemPlayer = MPMusicPlayerController.systemMusicPlayer()
//        if let _ = systemPlayer.nowPlayingItem {
//            systemPlayer.play()
//        }
        
        controlLabel.setTitle("Mission Complete", forState: .Normal)
        missionComplete = true
        
//        if let navController = self.navigationController {
//            navController.popViewControllerAnimated(true)
//        }
    }
    
    func pauseMusic() {
        // TODO fade out?
//        MPMusicPlayerController.systemMusicPlayer().pause()
    }
    
    func playMusic() {
        // TODO fade in?
//        MPMusicPlayerController.systemMusicPlayer().play()
    }
    
    func didAddDestination(destLocation: CLLocationCoordinate2D, destinationName: String) {
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
        if musicOn && audioSession.otherAudioPlaying {
            pauseMusic()
        }
    }
}

