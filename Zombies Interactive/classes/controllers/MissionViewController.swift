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
                title: "Stage1")
            let stage2 = MomentBlock(moments: [Interim(lengthInSeconds: 90), Sound(fileNames: ["vignette_transition"])],
                title: "Stage2")
            let stage3 = MomentBlock(moments: [Interim(lengthInSeconds: 90), Sound(fileNames: ["vignette_transition","mission_completed"])],
                title: "Stage3")
            
            stages = [stage1, stage2, stage3]
        }
        
        experienceManager = ExperienceManager(title: missionTitle, momentBlocks: stages)
        
        ////////////////////////////////////////////////////////
        //[ SCAFFOLDING MANAGER : TREES ]
        ////////////////////////////////////////////////////////
        let scaffoldingManagerTree = ScaffoldingManager(experienceManager: experienceManager)
        
        // validation: prove that ten trees are present
        let momentblock_tree_validation = MomentBlockSimple(moments: [
            SynthVoiceMoment(content: "runner 5, our sensors signal that you're passing a patch of trees, which are filled with zombie activity if the leaf color is just right. if you see multiple trees up ahead, approach them and remain there until we record your position. if you see no trees, you're safe. continue."),
            FunctionMoment(execFunc: {()->Void in
                self.experienceManager.saveCurrentContext()
            }),
            Interim(lengthInSeconds: 10),
            ConditionalMoment(
                momentBlock_true: MomentBlockSimple(
                    moments: [
                        SynthVoiceMoment(content: "detected position. trees validated"),
                        SynthVoiceMoment(content: "this is an awesome find")
                    ],
                    title: "detected: true"
                ),
                momentBlock_false: MomentBlockSimple(
                    moments: [
                        SynthVoiceMoment(content: "you kept moving. no trees nearby i see."),
                        SynthVoiceMoment(content: "we've updated our intel")
                    ],
                    title: "detected: false"
                ),
                conditionFunc: {() -> Bool in
                    // true condition: user is stationary, so trees spotted
                    if let speed = self.experienceManager.dataManager?.currentLocation?.speed
                        where speed <= 1.2 {
                        if self.experienceManager.distanceBetweenSavedAndCurrentContext() <= 10 {
                            let currEvaluatingObject = scaffoldingManagerTree.curPulledObject!
                            self.experienceManager.dataManager?.updateWorldObject(currEvaluatingObject, information: [], validated: true)
                        }
                        else {
                            self.experienceManager.dataManager?.pushWorldObject(["label": "tree", "interaction" : "find_ten_trees", "variation" : "0"])
                        }
                        
                        return true
                    }
                    
                    // false condition: user moves on, no trees found
                    if self.experienceManager.distanceBetweenSavedAndCurrentContext() <= 10 {
                        let currEvaluatingObject = scaffoldingManagerTree.curPulledObject!
                        self.experienceManager.dataManager?.updateWorldObject(currEvaluatingObject, information: [], validated: false)
                    }
                    else {
                        self.experienceManager.dataManager?.pushWorldObject(["label": "tree(false)", "interaction" : "find_ten_trees", "variation" : "0"])
                    }
                    return false
                    
            }),
            SynthVoiceMoment(content: "good job - now move on"),
            ], title: "scaffold_trees(variation)",
               requirement: Requirement(conditions:[Condition.InRegion, Condition.ExistsObject],
                objectLabel: "tree", variationNumber: 0))
        
        // variation: asking additional info when ten trees are present (after validation)
        let momentblock_tree_variation = MomentBlockSimple(moments: [
            SynthVoiceMoment(content: "runner 5, our sensors signal that you're passing a patch of trees, which are filled with zombie activity if the leaf color is just right. if you see a tree with red leaves up ahead, stand by it until we tell you to move on. if you see no trees with red leaves, you're safe. continue."),
            Interim(lengthInSeconds: 10),
            ConditionalMoment(
                momentBlock_true: MomentBlockSimple(
                    moments: [
                        SynthVoiceMoment(content: "detected stop - tree location recorded."),
                        SynthVoiceMoment(content: "we'll send another team to decode the message")
                    ],
                    title: "detected:true"
                ),
                momentBlock_false: MomentBlockSimple(
                    moments: [
                        SynthVoiceMoment(content: "you're moving. no message I see"),
                        SynthVoiceMoment(content: "we have updated our intel")
                    ],
                    title: "detected:false"
                ),
                conditionFunc: {() -> Bool in
                    if let speed = self.experienceManager.dataManager?.currentLocation?.speed
                        //true condition: user is stationary
                        where speed <= 1.2 {
                        self.experienceManager.dataManager?.pushWorldObject(["label": "red_tree", "interaction" : "scaffold_red_tree", "variation" : "1"])
                        return true
                    }
                    //false condition: user keeps moving
                    self.experienceManager.dataManager?.pushWorldObject(["label": "red_tree(false)", "interaction" : "scaffold_red_tree", "variation" : "1"])
                    return false
            }),
            SynthVoiceMoment(content: "good job - now move on"),
            ], title: "scaffold_tree(variation)",
               requirement: Requirement(conditions:[Condition.InRegion, Condition.ExistsObject],
                objectLabel: "tree", variationNumber: 0))
        
        scaffoldingManagerTree.insertableMomentBlocks =
            [momentblock_tree_validation, momentblock_tree_variation]

        ////////////////////////////////////////////////////////
        //[ SCAFFOLDING MANAGER : LAMP ]
        ////////////////////////////////////////////////////////
        var scaffoldingManager = ScaffoldingManager(
            experienceManager: experienceManager)
        
        //[scaffolding: validation]
        let momentblock_lamp_validation = MomentBlockSimple(moments: [
            //instruction
            SynthVoiceMoment(content: "runer 5, our sensors signal a lamp post ahead within 10m, alluding to the existence of a live source of power. if you see it, approach it and remain there until we've recorded your position. if you see none, continue"),
            //moment that saves current context
            FunctionMoment(execFunc: {()->Void in
                self.experienceManager.saveCurrentContext()
            }),
            //wait for person to make decisive action
            Interim(lengthInSeconds: 10),
            //branch: stationary, then push location, if not
            ConditionalMoment(
                momentBlock_true: MomentBlockSimple(
                    moments: [
                        SynthVoiceMoment(content: "detected position - lamp validated"),
                        SynthVoiceMoment(content: "this is a great find")
                    ],
                    title: "detected:true"
                ),
                momentBlock_false: MomentBlockSimple(
                    moments: [
                        SynthVoiceMoment(content: "you're moving - no lamp I see"),
                        SynthVoiceMoment(content: "we have noted the absence")
                    ],
                    title: "detected:false"
                ),
                conditionFunc: {() -> Bool in
                    if let speed = self.experienceManager.dataManager?.currentLocation?.speed
                        //true condition: user is stationary
                        where speed <= 1.2 {
                        
                        //a. distance from polled position <= 10: validation
                        if self.experienceManager.distanceBetweenSavedAndCurrentContext() <= 10 {
                            let curEvaluatingObject = scaffoldingManager.curPulledObject!
                            self.experienceManager.dataManager?.updateWorldObject(curEvaluatingObject, information: [], validated: true)
                        }
                        //b. distance from polled position > 10: new
                        else {
                            self.experienceManager.dataManager?.pushWorldObject(["label": "lamp", "interaction" : "find_lamp", "variation" : "0"])
                        }
                        return true
                    }
                    //false condition: user keeps moving
                    //a. distance from polled position <= 10: validation
                    if self.experienceManager.distanceBetweenSavedAndCurrentContext() <= 10 {
                        let curEvaluatingObject = scaffoldingManager.curPulledObject!
                        self.experienceManager.dataManager?.updateWorldObject(curEvaluatingObject, information: [], validated: false)
                    }
                    //b. distance from polled position > 10: new
                    else {
                        self.experienceManager.dataManager?.pushWorldObject(["label": "lamp(false)", "interaction" : "find_lamp", "variation" : "0"])
                    }
                    return false
            }),
            SynthVoiceMoment(content: "good job - now move on"),
            ], title: "scaffold_lamp(validate)",
               requirement: Requirement(conditions:[Condition.InRegion, Condition.ExistsObject],
                objectLabel: "lamp"))
        
        
        //[scaffolding: variation]
        let momentblock_lamp_variation = MomentBlockSimple(moments: [
            //instruction
            SynthVoiceMoment(content: "runner 5, there should be a lamp post ahead within 20m, where our scout team state they've left an encrypted message. if you see the lamp post and it has something posted, approach it and remain there until we've recorded your position. if you see none, continue"),
            //wait for person to make decisive action
            Interim(lengthInSeconds: 10),
            //branch: stationary, then push location, if not
            ConditionalMoment(
                momentBlock_true: MomentBlockSimple(
                    moments: [
                        SynthVoiceMoment(content: "detected stop - message location recorded."),
                        SynthVoiceMoment(content: "we'll send another team to decode the message")
                    ],
                    title: "detected:true"
                ),
                momentBlock_false: MomentBlockSimple(
                    moments: [
                        SynthVoiceMoment(content: "you're moving - no message I see"),
                        SynthVoiceMoment(content: "we have noted the absence")
                    ],
                    title: "detected:false"
                ),
                conditionFunc: {() -> Bool in
                    if let speed = self.experienceManager.dataManager?.currentLocation?.speed
                        //true condition: user is stationary
                        where speed <= 1.2 {
                        self.experienceManager.dataManager?.pushWorldObject(["label": "lamp_poster", "interaction" : "scaffold_lamp_posters", "variation" : "1"])
                        return true
                    }
                    //false condition: user keeps moving
                    self.experienceManager.dataManager?.pushWorldObject(["label": "lamp_poster(false)", "interaction" : "scaffold_lamp_posters", "variation" : "1"])
                    return false
            }),
            SynthVoiceMoment(content: "good job - now move on"),
            ], title: "scaffold_lamp(variation)",
               requirement: Requirement(conditions:[Condition.InRegion, Condition.ExistsObject],
                objectLabel: "lamp", variationNumber: 0))
        
        scaffoldingManager.insertableMomentBlocks =
            [momentblock_lamp_validation, momentblock_lamp_variation]
        
        ////////////////////////////////////////////////////////
        //[ EXPERIENCE MANAGER ]
        ////////////////////////////////////////////////////////
        let block_intro = MomentBlock(moments: [Sound(fileNames: ["radio_static", "intel_team_intro", "radio_static", "vignette_transition"]), Interim(lengthInSeconds: 1), Sound(fileNames: ["vignette_transition"])],
                                 title: "block:intro")
        let block_transition = MomentBlock(moments: [Interim(lengthInSeconds: 90), Sound(fileNames: ["vignette_transition"])],
                                 title: "block:transition")
        let block_end = MomentBlock(moments: [Interim(lengthInSeconds: 90), Sound(fileNames: ["vignette_transition","mission_completed"])],
                                 title: "block:end")
        
        let block_poll = MomentBlock(moments: [
            //instruction
            Sound(fileNames: ["radio_static"]),
            SynthVoiceMoment(content: "runner 5, our sensors are going to conduct an initial scan of your current area to look for Zombies in the vicinity. Continue at regular pace."),
            Sound(fileNames: ["radio_static", "vignette_transition"]),
            //keep pulling opportunities
            OpportunityPoller(objectFilters:["label": "lamp"], lengthInSeconds: 10.0, pollEveryXSeconds: 2.0, scaffoldingManager: scaffoldingManager),
            ],title: "block:poll")
        
        let block_lamp_find = MomentBlock(moments: [
            //instruction
            Sound(fileNames: ["radio_static"]),
            SynthVoiceMoment(content: "runner 5, our sensors show signs of a lamp post ahead within 10 meters, alluding to the existence of a functioning power source. run up to it and remain if true, retain current pace if false"),
            //wait for person to make decisive action
            Interim(lengthInSeconds: 10),
            //branch: stationary, then push location, if not
            ConditionalMoment(
                momentBlock_true: MomentBlockSimple(
                    moments: [
                        SynthVoiceMoment(content: "you're stationary - lamp recorded"),
                        SynthVoiceMoment(content: "")
                    ],
                    title: "detected:true"
                ),
                momentBlock_false: MomentBlockSimple(
                    moments: [
                        SynthVoiceMoment(content: "you're moving - no lamp I see"),
                        SynthVoiceMoment(content: "absence has been recorded")],
                    title: "detected:false"
                ),
                conditionFunc: {() -> Bool in
                    if let speed = self.experienceManager.dataManager?.currentLocation?.speed
                        //true condition: user is stationary
                        where speed <= 1.2 {
                        self.experienceManager.dataManager?.pushWorldObject(["label": "lamp", "interaction" : "find_lamp", "variation" : "0"])
                        return true
                    }
                    //false condition: user keeps running
                    self.experienceManager.dataManager?.pushWorldObject(["label": "lamp(false)", "interaction" : "find_lamp", "variation" : "0"])
                    return false
            }),
            SynthVoiceMoment(content: "good job - now move on"),
            Sound(fileNames: ["radio_static", "vignette_transition"]),
            //
            //pause before next moment
            Interim(lengthInSeconds: 10)
            ],title: "block:lamp(find)")
        
        let block_lamp_false = MomentBlock(moments: [
            //instruction
            Sound(fileNames: ["radio_static"]),
            SynthVoiceMoment(content: "runner 5, our sensors detect Zombies in the area. If there exists an area without a lamp ahead within 10m, run into it and remain there in position in the shadows. If not, start sprinting. we'll let you known when you're clear"),
            Sound(fileNames: ["radio_static", "vignette_transition"]),
            //wait for person to make decisive action
            Interim(lengthInSeconds: 10),
            //branch: stationary, then push location, if not
            Sound(fileNames: ["radio_static"]),
            ConditionalMoment(
                momentBlock_true: MomentBlockSimple(
                    moments: [
                        SynthVoiceMoment(content: "you're stationary - remain in the shadows. Zombies have not detected your presence"),
                        SynthVoiceMoment(content: "")
                    ],
                    title: "detected:true"
                ),
                momentBlock_false: MomentBlockSimple(
                    moments: [
                        SynthVoiceMoment(content: "you're moving - maintain pace")
                    ],
                    title: "detected:false"
                ),
                conditionFunc: {() -> Bool in
                    if let speed = self.experienceManager.dataManager?.currentLocation?.speed
                        //true condition: user is stationary
                        where speed <= 1.2 {
                        self.experienceManager.dataManager?.pushWorldObject(["label": "lamp(false)", "interaction" : "find_lamp", "variation" : "0"])
                        return true
                    }
                    //false condition: user keeps running
                    self.experienceManager.dataManager?.pushWorldObject(["label": "lamp", "interaction" : "find_lamp", "variation" : "0"])
                    return false
            }),
            SynthVoiceMoment(content: "runner 5, great job - you're clear. feel free to move on"),
            //Sound(fileNames: ["radio_static", "vignette_transition"]),
            //
            //pause before next moment
            Interim(lengthInSeconds: 10)
            ],title: "block:lamp(false)")
        
        var momentBlocks: [MomentBlock] = [
            block_intro, block_poll,
            block_lamp_find,
            block_lamp_false,
            block_end ]
        experienceManager = ExperienceManager(title: missionTitle, momentBlocks: momentBlocks)
        
        //UPDATE EXPERIENCEMANAGER REFERENCES
        scaffoldingManager._experienceManager = experienceManager
        ConditionalMoment.experienceManager = experienceManager
        
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

