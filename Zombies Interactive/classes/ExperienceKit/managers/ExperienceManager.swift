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

/// Protocol for suscribing to ExperienceManager events
@objc protocol ExperienceManagerDelegate {
    optional func didBeginMoment()
    optional func didFinishMoment()
    optional func didBeginInterim()
    optional func didFinishInterim()
    optional func didBeginSound()
    optional func didFinishSound()
    optional func didBeginMomentBlock()
    optional func didFinishMomentBlock()
    optional func didFinishExperience()
    optional func didAddDestination(destLocation: CLLocationCoordinate2D, destinationName: String)
}

/// Contains all logic for playing the experience, saving data, etc. Implement ExperienceManagerDelegate protocol for more custom logic.
class ExperienceManager: NSObject, OpportunityManagerDelegate {
    
    var isPlaying = false
    var momentBlocks = [MomentBlock]()
    var currentMomentBlockIdx = -1
    
    // should be optional whether their experience will collect data, especially location always
    var dataManager: DataManager?
    var opportunityManager: OpportunityManager?
    var scaffoldingManager: ScaffoldingManager?
    
    var experienceStarted = false
    var experience: Experience?
    var delegate: ExperienceManagerDelegate?
    
    var opportunityTimer = NSTimer()
    
    
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
    
    init(title: String, momentBlocks: [MomentBlock], MomentBlockSimplePool: [MomentBlockSimple]?=nil) {
        self.momentBlocks = momentBlocks
        self.experience = Experience()
        self.experience?.title = title
        self.dataManager = DataManager(experience: self.experience!)
        if let _ = MomentBlockSimplePool {
            opportunityManager = OpportunityManager(MomentBlockSimplePool: MomentBlockSimplePool!)
        }
        
        
        super.init()
        
        for momentBlock in momentBlocks{
            momentBlock.eventManager.listenTo("MomentBlockFinished", action: nextMomentBlock)
            momentBlock.eventManager.listenTo("startingInterim", action: handleInterimStart)
            momentBlock.eventManager.listenTo("startingSound", action: handleSoundStart)
            momentBlock.eventManager.listenTo("choseRandomMomentBlockSimple", action: updateMomentBlockSimplePool)
            
            if let dataManager = dataManager {
                momentBlock.eventManager.listenTo("sensorCollectorStarted", action: dataManager.startCollecting)
                momentBlock.eventManager.listenTo("sensorCollectorEnded", action: dataManager.stopCollecting)
                
//                MomentBlock.eventManager.listenTo("foundWorldObject", action: dataManager.recordWorldObject)
            }
        }

    
    }
    
    func handleInterimStart(information: Any?) {
        print(" (ExperienceManager::handleInterimStart)")
        delegate?.didBeginInterim?()
        
        if let MomentBlock = currentMomentBlock,
            moment = MomentBlock.currentMoment,
            _ = opportunityManager
            where moment.canEvaluateOpportunity
        {
            //resetOpportunityTimer(information)
            print("\n (ExperienceManager::handleSoundStart) + canEvaluateOpportunity (title:\(moment.title))")
            attemptInsertMomentBlockSimple()
        }
    }
    
    func handleSoundStart(information: Any?) {
        delegate?.didBeginSound?()
        
        if let MomentBlock = currentMomentBlock,
        moment = MomentBlock.currentMoment,
        _ = opportunityManager
        where moment.canEvaluateOpportunity
        {
            //resetOpportunityTimer(information)
            //print("\n (ExperienceManager::handleSoundStart) + canEvaluateOpportunity (title:\(moment.title))")
            //attemptInsertMomentBlockSimple()
        }
    }
    
    func updateMomentBlockSimplePool(information: Any?) {

        if let infoDict = information as? [String : String],
            MomentBlockSimpleTitle = infoDict["MomentBlockSimpleTitle"] {
            print("  removing \(MomentBlockSimpleTitle) from pool")
                
            // remove this MomentBlockSimple from potentially being included in  future MomentBlocks
            for momentBlock in momentBlocks {
                if let idx = momentBlock.MomentBlockSimplePool?.indexOf({ (MomentBlockSimple) -> Bool in
                    return MomentBlockSimple.title == MomentBlockSimpleTitle
                }) {
                    momentBlock.MomentBlockSimplePool?.removeAtIndex(idx)
                }
            }
        
        }
    }

    
    func start() {
        print("\n[ExperienceManager::start] Experience started")
        isPlaying = true
        self.experience?.user = PFUser.currentUser()
        self.experience?.dateStarted = NSDate()
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
        dataManager?.stopUpdatingLocation()
        
        self.experience?.dateCompleted = NSDate()
        self.experience?.completed = true
        self.experience?.saveInBackground()
  
        delegate?.didFinishExperience?()
    }
    
    
    func resetOpportunityTimer(information: Any?) {
        // FIXME this won't work as [String:AnyObject], even though it worked for datamanager?
        
        print(" (ExperienceManager::resetOpportunityTimer)")
        if let infoDict = information as? [String : String],
        durationString = infoDict["duration"],
        duration = Float(durationString) {
                
            if opportunityTimer.valid {
                opportunityTimer.invalidate()
            }
                
            let midDurationTime = duration/2 // TODO randomize this a bit?
            opportunityTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(midDurationTime), target: self, selector: #selector(OpportunityManagerDelegate.attemptInsertMomentBlockSimple), userInfo: nil, repeats: false)
            print("  Opportunity check in \(round(midDurationTime)) seconds")
        }
    }
    
    func insertMomentBlockSimple( momentBlockSimple: MomentBlockSimple )
    {
        if let  curMomentBlock = currentMomentBlock,
            curMoment = curMomentBlock.currentMoment {
            curMomentBlock.insertMomentsAtIndex(momentBlockSimple.moments,
                                                idx: curMomentBlock.currentMomentIdx + 1)
        }
    }
    
    func attemptInsertMomentBlockSimple() {
        print("  (ExperienceManager) Checking opportunity...")
        if let om = opportunityManager,
        momentBlock = currentMomentBlock,
        moment = momentBlock.currentMoment,
        momentBlockSimple = om.getBestFitMomentBlockSimple(currentContext)
            
        //isPlaying: when experience is not paused + has started
        //moment.isInterruptable:
        where isPlaying {
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