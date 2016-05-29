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
    var musicOn: Bool = true
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
            nextMomentButton.hidden = false
            #endif
            startDate = NSDate()
            let _ = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateTimeElapsed"), userInfo: nil, repeats: true)
            
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: "back:")
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
        
        let findHydrantInstruct = Sound(fileNames: ["radio_static", "our_monitors_show", "radio_static"])
        let findHydrantCollector = SensorCollector(lengthInSeconds: 30, dataLabel: "fire_hydrant", sensors: [.Location, .Speed])
        let findFireHydrant = MomentBlockSimple(moments: [findHydrantInstruct, findHydrantCollector, Sound(fileNames: ["radio_static", "you've_thrown_off","radio_static"])], title: "Sprint to hydrant")
        

        let passTenTreesInstruct = Sound(fileNames: ["radio_static", "weve_noticed_increased", "radio_static"])
        let passTenTreesCollector = SensorCollector(lengthInSeconds: 25, dataLabel: "tree", sensors: [.Location, .Speed])
        let passTenTrees = MomentBlockSimple(moments: [passTenTreesInstruct, passTenTreesCollector, Sound(fileNames: ["radio_static","you_should_be","radio_static"])], title: "Sprint past ten trees")
        
        let sprintToBuildingInstruct = Sound(fileNames: ["radio_static", "the_radars_on", "radio_static"])
        let sprintToBuildingCollector = SensorCollector(lengthInSeconds: 20, dataLabel: "tall_building", sensors: [.Location, .Speed])
        let sprintToBuilding = MomentBlockSimple(moments: [sprintToBuildingInstruct, sprintToBuildingCollector, Sound(fileNames: ["radio_static","building_confirmed","radio_static"])], title: "Sprint to tall building")
        
        let sprintingInteractions = [findFireHydrant, sprintToBuilding, passTenTrees]
        
        
        
        
        // Construct the experience based on selected mission
        var stages: [MomentBlock] = []
        if missionTitle == "Intel Mission" {

            let stage1 = MomentBlock(moments: [Sound(fileNames: ["radio_static", "intel_team_intro", "radio_static", "vignette_transition"]), Interim(lengthInSeconds: 90), Sound(fileNames: ["vignette_transition"])],
                title: "Stage1", MomentBlockSimpleInsertionIndices: [2], MomentBlockSimplePool: sprintingInteractions)
            let stage2 = MomentBlock(moments: [Interim(lengthInSeconds: 90), Sound(fileNames: ["vignette_transition"])],
                title: "Stage2", MomentBlockSimpleInsertionIndices: [1], MomentBlockSimplePool: sprintingInteractions)
            let stage3 = MomentBlock(moments: [Interim(lengthInSeconds: 90), Sound(fileNames: ["vignette_transition","mission_completed"])],
                title: "Stage3", MomentBlockSimpleInsertionIndices: [1], MomentBlockSimplePool: sprintingInteractions)
            
            stages = [stage1, stage2, stage3]
        }
        experienceManager = ExperienceManager(title: missionTitle, momentBlocks: stages)

        //SCAFFOLDING MANAGER
        var scaffoldingManager = ScaffoldingManager(
            experienceManager: experienceManager)
        
        let momentblock_hydrant = MomentBlockSimple(moments: [
            //instruction
            SynthVoiceMoment(content: "there is a a fire hydrant 3 meters ahead"),
            ], title: "scaffold_fire_hydrant",
               requirement: Requirement(conditions:[Condition.InRegion, Condition.ExistsObject],
                objectLabel: "fire_hydrant"))
        let momentblock_tree = MomentBlockSimple(moments: [
            //instruction
            SynthVoiceMoment(content: "there is a a tree within 3 second walking distance. if you feel comfortable, walk to it and stand for 10 seconds. if you would rather not, continue your path"),
            //wait for person to make decisive action
            Interim(lengthInSeconds: 2),
            //branch: stationary, then push location, if not
            ConditionalMoment(
                moment_true: SynthVoiceMoment(content: "detected stop - tree recorded"),
                moment_false: SynthVoiceMoment(content: "you're moving - no tree I see"),
                conditionFunc: {() -> Bool in
                    if let speed = self.experienceManager.dataManager?.currentLocation?.speed
                        //true condition: user is stationary
                        where speed <= 1.2 {
                        let curEvaluatingObject = scaffoldingManager.curPulledObject!
                        self.experienceManager.dataManager?.updateWorldObject(curEvaluatingObject, information: [], validated: true)
                        return true
                    }
                    //false condition: user keeps moving
                    let curEvaluatingObject = scaffoldingManager.curPulledObject!
                    self.experienceManager.dataManager?.updateWorldObject(curEvaluatingObject, information: [], validated: false)
                    return false
            }),
            SynthVoiceMoment(content: "good job - now move on"),
            ], title: "scaffold_tree",
               requirement: Requirement(conditions:[Condition.InRegion, Condition.ExistsObject],
                objectLabel: "tree"))
        
        
        //[scaffolding: variation]
        let momentblock_tree_var0 = MomentBlockSimple(moments: [
            //instruction
            SynthVoiceMoment(content: "there is a a tree 3 meters ahead. does it have green leaves?"),
            ConditionalMoment(
                moment_true: SynthVoiceMoment(content: "detected stop - green leaves recorded"),
                moment_false: SynthVoiceMoment(content: "you're moving - no green leaves I see"),
                conditionFunc: {() -> Bool in
                    if let speed = self.experienceManager.dataManager?.currentLocation?.speed
                        //true condition: user is stationary
                        where speed <= 1.2 {
                        self.experienceManager.dataManager?.pushWorldObject(["label": "tree_leaves_green", "interaction" : "scaffold_tree_leaves_green", "variation" : "1"])
                        return true
                    }
                    //false condition: user keeps moving
                    self.experienceManager.dataManager?.pushWorldObject(["label": "tree_leaves_green(false)", "interaction" : "scaffold_tree_leaves_green", "variation" : "1"])
                    return false
            }),
            SynthVoiceMoment(content: "good job - now move on"),
            ], title: "scaffold_tree_var0",
               requirement: Requirement(conditions:[Condition.InRegion, Condition.ExistsObject],
                objectLabel: "tree", variationNumber: 0))
        
        scaffoldingManager.insertableMomentBlocks = [momentblock_hydrant, momentblock_tree, momentblock_tree_var0]
        
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
        do {
            try AVAudioSession.sharedInstance().setActive(false, withOptions: .NotifyOthersOnDeactivation)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        let systemPlayer = MPMusicPlayerController.systemMusicPlayer()
        if let _ = systemPlayer.nowPlayingItem {
            systemPlayer.play()
        }
        
        controlLabel.setTitle("Mission Complete", forState: .Normal)
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

