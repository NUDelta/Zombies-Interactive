//
//  ExperienceManager.swift
//
//
//  Created by Scott Cambo on 8/17/15.
//
//

import Foundation
import AVFoundation
import CoreLocation
import Parse
import CoreMotion
import MediaPlayer
import MapKit

/// Protocol for suscribing to ExperienceManager events
@objc protocol ExperienceManagerDelegate {
    @objc optional func didBeginMoment()
    @objc optional func didFinishMoment()
    @objc optional func didBeginInterim()
    @objc optional func didFinishInterim()
    @objc optional func didBeginSound()
    @objc optional func didFinishSound()
    @objc optional func didBeginMomentBlock()
    @objc optional func didFinishMomentBlock()
    @objc optional func didFinishExperience()
    @objc optional func didAddDestination(_ destLocation: CLLocationCoordinate2D, destinationName: String)
}

/// Contains all logic for playing the experience, saving data, etc. Implement ExperienceManagerDelegate protocol for more custom logic.
class ExperienceManager: NSObject, OpportunityManagerDelegate {
    
    var isPlaying = false
    var momentBlocks = [MomentBlock]()
    var currentMomentBlockIdx = -1
    var run_id = ""
    var user_id = ""
    
    var dataManager: DataManager?
    var opportunityManager: OpportunityManager?
    var scaffoldingManager: ScaffoldingManager?
    
    var experienceStarted = false
    var experience: Experience?
    var delegate: ExperienceManagerDelegate?
    
    var opportunityTimer = Timer()
    
    var currentMomentBlock: MomentBlock? {
        get { return momentBlocks[safe: currentMomentBlockIdx] }
    }
    
    var tempSavedContext: Context? //used to save a context of interest
    var currentContext: Context {
        get {
            return Context(
                        timeElapsed: 0, // TODO implement time elapsed
                        timeRemaining: 0, // TODO estimate time remaining based on time elapsed and total time (precalculated)
                        speed: dataManager?.currentLocation?.speed,
                        location: dataManager?.currentLocation?.coordinate,
                        heading: dataManager?.currentHeading)
        }
    }
    
    func getCurrentSavedContext() -> Context? {
        return tempSavedContext
    }
    func saveCurrentContext() {
        tempSavedContext = currentContext
    }
    func distanceBetweenSavedAndCurrentContext() -> Double {
        let loc_cur = MKMapPointForCoordinate(self.getCurrentSavedContext()!.location!)
        let dis = MKMetersBetweenMapPoints(
            loc_cur,
            MKMapPointForCoordinate(self.currentContext.location!)
        )
        return dis
    }
    
    init(title: String, momentBlocks: [MomentBlock], MomentBlockSimplePool: [MomentBlockSimple]?=nil) {
            super.init()
            self.momentBlocks = momentBlocks
            self.experience = Experience()
            self.experience?.title = title
            if let _ = MomentBlockSimplePool {
                opportunityManager = OpportunityManager(MomentBlockSimplePool: MomentBlockSimplePool!)
            }
        
            // init was here
        
            self.dataManager = DataManager(experienceManager: self, experience: self.experience!)

        
            for momentBlock in momentBlocks{
                momentBlock.eventManager.listenTo("MomentBlockFinished", action: nextMomentBlock)
                momentBlock.eventManager.listenTo("startingInterim", action: handleInterimStart)
                momentBlock.eventManager.listenTo("startingSound", action: handleSoundStart)
                momentBlock.eventManager.listenTo("choseRandomMomentBlockSimple", action: updateMomentBlockSimplePool)
                
                
                if let dataManager = dataManager {
                    momentBlock.eventManager.listenTo("sensorCollectorStarted", action: dataManager.startCollecting)
                    momentBlock.eventManager.listenTo("sensorCollectorEnded", action: dataManager.stopCollecting)
                    momentBlock.eventManager.listenTo("verifyMoment", action: dataManager.verifyMoment)
                    
    //                MomentBlock.eventManager.listenTo("foundWorldObject", action: dataManager.recordWorldObject)
                }
            }
    }
    
    func handleInterimStart(_ information: Any?) {
        print(" (ExperienceManager::handleInterimStart)")
        delegate?.didBeginInterim?()
        
        if let MomentBlock = currentMomentBlock,
            let moment = MomentBlock.currentMoment,
            let _ = opportunityManager, moment.canEvaluateOpportunity
        {
            //resetOpportunityTimer(information)
            print("\n (ExperienceManager::handleSoundStart) + canEvaluateOpportunity (title:\(moment.title))")
            attemptInsertMomentBlockSimple()
        }
    }
    
    func handleSoundStart(_ information: Any?) {
        delegate?.didBeginSound?()
        
        if let MomentBlock = currentMomentBlock,
        let moment = MomentBlock.currentMoment,
        let _ = opportunityManager, moment.canEvaluateOpportunity
        {
            //resetOpportunityTimer(information)
            //print("\n (ExperienceManager::handleSoundStart) + canEvaluateOpportunity (title:\(moment.title))")
            //attemptInsertMomentBlockSimple()
        }
    }
    
    func updateMomentBlockSimplePool(_ information: Any?) {

        if let infoDict = information as? [String : String],
            let MomentBlockSimpleTitle = infoDict["MomentBlockSimpleTitle"] {
            print("  removing \(MomentBlockSimpleTitle) from pool")
                
            // remove this MomentBlockSimple from potentially being included in  future MomentBlocks
            for momentBlock in momentBlocks {
                if let idx = momentBlock.MomentBlockSimplePool?.index(where: { (MomentBlockSimple) -> Bool in
                    return MomentBlockSimple.title == MomentBlockSimpleTitle
                }) {
                    momentBlock.MomentBlockSimplePool?.remove(at: idx)
                }
            }
        
        }
    }

    
    func start() {
        print("\n[ExperienceManager::start] Experience started")
        isPlaying = true
        self.experience?.user = PFUser.current()
        self.experience?.dateStarted = Date()
        self.experience?.completed = false
        self.experience?.saveInBackground()
        experienceStarted = true
        
        self.nextMomentBlock()
        dataManager?.startUpdatingLocation()
    }
    
    
    func play() {
        isPlaying = true
        
        dataManager?.startUpdatingLocation()
        
        if experienceStarted == false {
            self.start()
        } else {
            currentMomentBlock?.play()
        }
    }
    
    
    func pause() {
        dataManager?.stopUpdatingLocation()
        
        isPlaying = false
        currentMomentBlock?.pause()
    }
    
    func nextMomentBlock() {
        self.currentMomentBlockIdx += 1
        print("\n--next moment block (idx:\(currentMomentBlockIdx))--")
        if self.currentMomentBlockIdx < momentBlocks.count {
            self.currentMomentBlock?.start()
        } else {
            self.finishExperience()
        }
    }
    
    
    func finishExperience() {
        print("\nFinished experience")
        let end_text = "Good work out there, Runner 5. See you next time."
        let endAudio:SynthVoiceMoment = SynthVoiceMoment(title: "end", isInterruptable: false, content: end_text)
        let newEndMoment = MomentBlockSimple(moments: [Sound(fileNames:["radio_static"]), endAudio, Sound(fileNames:["radio_static"])], title:"expand moment block", canInsertImmediately: true)
        self.insertMomentBlockSimple(newEndMoment)
        dataManager?.stopUpdatingLocation()
        self.experience?.dateCompleted = Date()
        self.experience?.completed = true
        self.experience?.saveInBackground()
        delegate?.didFinishExperience?()
    }
    
    
    func resetOpportunityTimer(_ information: Any?) {
        // FIXME this won't work as [String:AnyObject], even though it worked for datamanager?
        
        print(" (ExperienceManager::resetOpportunityTimer)")
        if let infoDict = information as? [String : String],
        let durationString = infoDict["duration"],
        let duration = Float(durationString) {
                
            if opportunityTimer.isValid {
                opportunityTimer.invalidate()
            }
                
            let midDurationTime = duration/2 // TODO randomize this a bit?
            opportunityTimer = Timer.scheduledTimer(timeInterval: TimeInterval(midDurationTime), target: self, selector: #selector(OpportunityManagerDelegate.attemptInsertMomentBlockSimple), userInfo: nil, repeats: false)
            print("  Opportunity check in \(round(midDurationTime)) seconds")
        }
    }
    
    func insertMomentBlockSimple( _ momentBlockSimple: MomentBlockSimple )
    {
        if let curMomentBlock = currentMomentBlock,
            let curMoment = curMomentBlock.currentMoment {
            if let dataManager = dataManager  {
                curMoment.eventManager.listenTo("verifyMoment", action: dataManager.verifyMoment)
            }
            if curMoment.isInterruptable || momentBlockSimple.canInsertImmediately {
                curMomentBlock.insertMomentsAtIndex(momentBlockSimple.moments,
                                                    idx: curMomentBlock.currentMomentIdx + 1)
                curMoment.finished()
            }
        }
    }
    
    func attemptInsertMomentBlockSimple() {
        print("  (ExperienceManager) Checking opportunity...")
        if let om = opportunityManager,
        let momentBlock = currentMomentBlock,
        let moment = momentBlock.currentMoment,
        let momentBlockSimple = om.getBestFitMomentBlockSimple(currentContext), isPlaying {
            print("  \n(ExperienceManager::attemptInsertMomentBlockSimple) Inserting MomentBlockSimple '\(momentBlockSimple.title)'.")
            
            // add pin on map if it's location based
            //delegate?.didAddDestination?(MomentBlockSimple.requirement.region.center, destinationName: MomentBlockSimple.requirement.region.identifier)
            
            if moment.isInterruptable {
                print("--moment is interruptable--")
            }
            if momentBlockSimple.canInsertImmediately {
                print("--MomentBlockSimple can insert immediately--")
            }
            if moment.canEvaluateOpportunity {
                print("--force delaying current moment--")
                //readd in current moment to the next index (delay effect)
                //Note: we're adding in these moments to the current MomentBlock
                //momentBlock.insertMomentsAtIndex([moment], idx: MomentBlock.currentMomentIdx + 1)
                momentBlock.insertMomentsAtIndex(momentBlockSimple.moments, idx: momentBlock.currentMomentIdx + 1)
                //moment.finished()
            }
            else if moment.isInterruptable || momentBlockSimple.canInsertImmediately {
                print("--force finishing current moment--")
                momentBlock.insertMomentsAtIndex(momentBlockSimple.moments, idx: momentBlock.currentMomentIdx + 1)
                moment.finished()
            }
            else {
                momentBlock.insertMomentsAtIndex(momentBlockSimple.moments, idx: momentBlock.currentMomentIdx + 1)
                print("--MomentBlockSimple will be starting once cur moment finishes--")
            }
        } else {
            let isInterruptable = currentMomentBlock?.currentMoment?.isInterruptable
            print("  \n(ExperienceManage::attemptInsertMomentBlockSimple) No MomentBlockSimples fit the current context. (ExperienceManager.isPlaying:\(isPlaying), moment.isInterrutable:\(isInterruptable)")
        }
    }
}
