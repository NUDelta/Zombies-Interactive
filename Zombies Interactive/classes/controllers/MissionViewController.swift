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

// should implement an ExperienceManager delegate for events like silenceDidStart

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
        let currentMoment = self.experienceManager.currentStage?.currentMoment
        (currentMoment as? Sound)?.player?.stop()
        
        if self.experienceManager.isPlaying == false {
            self.controlLabel.setTitle("Pause", forState: .Normal)
        }
        
        currentMoment?.finished()
    }
    
    @IBAction func nextMoment(sender: AnyObject) {
        // FIX this requires too much knowledge of internals for another developer to use
        
        let currentMoment = self.experienceManager.currentStage?.currentMoment
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
            let timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateTimeElapsed"), userInfo: nil, repeats: true)
            
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
        
        
        // regions -- should be pulled from Parse in the future, probably
        // get only "verified" ones
//        let chickenShackLocation = CLLocationCoordinate2D(latitude: 42.052860617171845, longitude: -87.68747791910707)
//        let chickenShackRegion = CLCircularRegion(center: chickenShackLocation, radius: 300, identifier: "Chicken Shack")
//        
//        let techLocation = CLLocationCoordinate2D(latitude: 42.057789, longitude: -87.676150)
//        let techRegion = CLCircularRegion(center: techLocation, radius: 1000, identifier: "Tech Institute")
        
  
        /*
        *
        *  MARK: Interaction definitions
        *
        */
        
        // Identify vantage points
        let identifyBuildings = KnockListener(title: "Identify Vantage Points",
                                            lengthInSeconds: 2.minutesToSeconds,
                                            dataLabel: "tall_building",
                                            recordMultiple: true,
                                            requireDoubleKnock: true)
        let knockForBuildingsRequirement = Requirement(conditions: [.TimeElapsed], seconds: -1)
        let knockForBuildings = Interaction(moments: [Sound(fileNames: ["radio_static", "vantage_points_1", "radio_static"]),
                                                      identifyBuildings,
                                                      Sound(fileNames: ["radio_static", "vantage_points_2", "radio_static"])],
                                            title: "Identify Vantage Points",
                                            requirement: knockForBuildingsRequirement)
        
        // Find tree cover and stretch
        let stretchAtTree = SensorCollector(lengthInSeconds: 90, title: "Get Cover and Stretch", dataLabel: "tree", sensors: [.Location])
        let getCoverAtTree = Interaction(moments: [Sound(fileNames: ["find_cover"]),
                                                   stretchAtTree,
                                                   Sound(fileNames: ["leave_cover"])],
                                         title: "Get to Cover!")
        
        // Take cover at known building
        // TODO directional instruction tech
        // for now, just put a pin on their map
//        let takeCoverAtBuilding = 
        
        // Avoid zombies by taking high route
        // TODO set up altitude data saving
        let monitorAltitude = SensorCollector(lengthInSeconds: 150, dataLabel: "high_point", sensors: [.Location, .Altitude])
        let takeHighRoute = Interaction(moments: [Sound(fileNames: ["radio_static", "high_route_1", "radio_static",]),
                                                  monitorAltitude],
                                        title: "Take High Route")
        
        // Go fast past the zombie hangout
        let monitorSpeed = SensorCollector(lengthInSeconds: 30, dataLabel: "stop_sign", sensors: [.Location, .Speed])
        let passZombieHotspot = Interaction(moments: [Sound(fileNames: ["radio_static", "stopsign_hotspot_1", "radio_static",]),
                                                      monitorSpeed,
                                                      Sound(fileNames: ["radio_static", "stopsign_hotspot_2", "radio_static",])],
                                            title: "Pass Zombie Hotspot")
        
        // Find somewhere to sit and rest
        let monitorStop = SensorCollector(lengthInSeconds: 20, dataLabel: "rest_place", sensors: [.Location, .Speed])
        let findRestPlace = Interaction(moments: [Sound(fileNames: ["radio_static", "find_rest_1", "radio_static",]),
                                                  monitorStop,
                                                  Sound(fileNames: ["radio_static", "find_rest_2", "radio_static",])],
                                        title: "Pass Zombie Hotspot")
        
        /*
        *
        * MARK: Sprinting interactions
        *   
        */
        
//        let findHydrantInstruct = Sound(fileNames: ["radio_static", "our_monitors_show", "radio_static"])
//        let findHydrantCollector = SensorCollector(lengthInSeconds: 20, dataLabel: "fire_hydrant", sensors: [.Location, .Speed])
        let findHydrantInstructCollector = CollectorWithSound(fileNames: ["radio_static", "our_monitors_show", "radio_static"], additionalTime: 20, dataLabel: "fire_hydrant", sensors: [.Location, .Speed])
        let findFireHydrant = Interaction(moments: [findHydrantInstructCollector, Sound(fileNames: ["radio_static", "you've_thrown_off","radio_static"])], title: "Sprint to hydrant")
        

//        let passTenTreesInstruct = Sound(fileNames: ["radio_static", "weve_noticed_increased", "radio_static"])
//        let passTenTreesCollector = SensorCollector(lengthInSeconds: 20, dataLabel: "tree", sensors: [.Location, .Speed])
        let passTenTreesInstructCollector = CollectorWithSound(fileNames: ["radio_static", "weve_noticed_increased", "radio_static"], additionalTime: 20, dataLabel: "tree", sensors: [.Location, .Speed])
        let passTenTrees = Interaction(moments: [passTenTreesInstructCollector, Sound(fileNames: ["radio_static","you_should_be","radio_static"])], title: "Sprint past ten trees")
        
//        let sprintToBuildingInstruct = Sound(fileNames: ["radio_static", "the_radars_on", "radio_static"])
//        let sprintToBuildingCollector = SensorCollector(lengthInSeconds: 20, dataLabel: "tall_building", sensors: [.Location, .Speed])
        let sprintToBuildingInstructCollector = CollectorWithSound(fileNames: ["radio_static", "the_radars_on", "radio_static"], additionalTime: 20, dataLabel: "tall_building", sensors: [.Location, .Speed])
        let sprintToBuilding = Interaction(moments: [sprintToBuildingInstructCollector, Sound(fileNames: ["radio_static","building_confirmed","radio_static"])], title: "Sprint to tall building")
        
        let sprintingInteractions = [findFireHydrant, sprintToBuilding, passTenTrees]
        
        
        let allInteractions = [knockForBuildings, getCoverAtTree, takeHighRoute, passZombieHotspot, findRestPlace] + sprintingInteractions
        
        
        // Construct the experience based on selected mission
        var stages: [Stage] = []
        switch missionTitle {
        case "S1M16: Scouting Mission (~45 min)":

            /*
            *
            * MARK: mission construction
            *
            */
            // http://zombiesrun.wikia.com/wiki/Scouting_Mission#
            let stage1 = Stage(moments: [Sound(fileNames: ["S1M16_1"]), Interim(lengthInSeconds: 2.minutesToSeconds), Interim(lengthInSeconds: 120)],
                title: "Scouting", interactionInsertionIndices: [2], interactionPool: sprintingInteractions)
            let stage2 = Stage(moments: [Sound(fileNames: ["S1M16_2"]), Interim(lengthInSeconds: 2.minutesToSeconds), Interim(lengthInSeconds: 120)], title: "No More Eyes", interactionInsertionIndices: [2], interactionPool: sprintingInteractions)
            let stage3 = Stage(moments: [Sound(fileNames: ["S1M16_3"]), Interim(lengthInSeconds: 2.minutesToSeconds), Interim(lengthInSeconds: 120)], title: "Gunshots", interactionInsertionIndices: [2], interactionPool: sprintingInteractions)
            let stage4 = Stage(moments: [Sound(fileNames: ["S1M16_4"]), Interim(lengthInSeconds: 5.minutesToSeconds)], title: "A Mystery")
            let stage5 = Stage(moments: [Sound(fileNames: ["S1M16_5"]), Interim(lengthInSeconds: 5.minutesToSeconds)], title: "Swift Exit")
            let stage6 = Stage(moments: [Sound(fileNames: ["S1M16_6"]), Interim(lengthInSeconds: 5.minutesToSeconds)], title: "Pursuit")
            let stage7 = Stage(moments: [Sound(fileNames: ["S1M16_7", "S1M16_8", "mission_completed"])], title: "Debrief")

            stages = [stage1, stage2, stage3, stage4, stage5, stage6, stage7]
            
            experienceManager = ExperienceManager(title: missionTitle, stages: stages)
            break
            

        case "Intel Team Missions 1 (<15min)":
            // Demos all of the interactions
            
            var transitions = [Sound]()
            for var i=0; i < allInteractions.count; i++ {
                transitions.append(Sound(fileNames: ["vignette_transition"]))
            }
            
            let stage1 = Stage(moments: [Sound(fileNames: ["radio_static", "intel_team_intro", "radio_static"])] +
                                        transitions +
                                        [Sound(fileNames: ["radio_static", "intel_missions_end", "radio_static"])],
                                title: "All Interaction Stage",
                                interactionInsertionIndices: [2,3,4,5,6],
                                interactionPool: allInteractions)
            
            
            stages = [stage1]
            
            // Zombie music: https://www.youtube.com/watch?v=vClu9SCxHhI&spfreload=10
            
            experienceManager = ExperienceManager(title: missionTitle, stages: stages)
            
            break
            
        default:
            experienceManager = ExperienceManager(title: missionTitle, stages: stages)
            break
        
        }
        
        
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

        if self.experienceManager.currentStageIdx > -1 && missionComplete == false {
            
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

