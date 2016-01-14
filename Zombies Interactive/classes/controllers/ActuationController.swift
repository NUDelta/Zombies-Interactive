//
//  ActuationController.swift
//  Zombies Interactive
//
//  Created by Scott Cambo on 9/10/15.
//  Copyright (c) 2015 Scott Cambo. All rights reserved.
//


/* CREDIT : A lot of this code was repurposed from this github account
https://github.com/DharmeshKheni/OpenEars-with-Swift-/blob/master/SpeechToText/ViewController.swift
*/

import Foundation

var lmPath: String!
var dicPath: String!
var words: Array<String> = []
var currentWord: String!

var kLevelUpdatesPerSecond = 18

class OpenEarsController: NSObject, OEEventsObserverDelegate{
    var openEarsEventsObserver = OEEventsObserver()
    var currentHypothesis:String = ""
    var startupFailedDueToLackOfPermissions = Bool()
    let events = EventManager()
    
    init(wordsToRecognize:[String]){
        super.init()
        self.openEarsEventsObserver = OEEventsObserver()
        self.openEarsEventsObserver.delegate = self
        
        let lmGenerator: OELanguageModelGenerator = OELanguageModelGenerator()
        
        words = wordsToRecognize
        let name = "LanguageModelFileStarSaver"
        lmGenerator.generateLanguageModelFromArray(words, withFilesNamed: name, forAcousticModelAtPath: OEAcousticModel.pathToModel("AcousticModelEnglish"))
        
        lmPath = lmGenerator.pathToSuccessfullyGeneratedLanguageModelWithRequestedName(name)
        dicPath = lmGenerator.pathToSuccessfullyGeneratedDictionaryWithRequestedName(name)
    }
    
    // OEEventsObserver delegate methods
    func pocketsphinxDidReceiveHypothesis(hypothesis: String!, recognitionScore: String!, utteranceID: String!) {
        print("  The received hypothesis is " + hypothesis + " with a score of " + recognitionScore + " and an ID of " + utteranceID)
        // if score is a certain certainty and that word is in words,
        // then send an event trigger for whatever is listening
        self.currentHypothesis = hypothesis
        if words.contains(currentHypothesis){
            print("  found word: " + currentHypothesis)
            self.events.trigger("heardWord", information: hypothesis)
        }
        // add the hypothesis to wherever you wanna store it
    }
    
    func startListening() {
        do {
            try OEPocketsphinxController.sharedInstance().setActive(true)
        } catch _ {
        }
        OEPocketsphinxController.sharedInstance().startListeningWithLanguageModelAtPath(lmPath, dictionaryAtPath: dicPath, acousticModelAtPath: OEAcousticModel.pathToModel("AcousticModelEnglish"), languageModelIsJSGF: false)
    }
    
    func stopListening() {
        OEPocketsphinxController.sharedInstance().stopListening()
    }
    
    func pocketsphinxDidStartListening() {
        print("  Pocketsphinx is now listening.")
    }
    
    func pocketsphinxDidDetectSpeech() {
        print("  Pocketsphinx has detected speech.")
    }
    
    func pocketsphinxDidDetectFinishedSpeech() {
        print("  Pocketsphinx has detected a period of silence, concluding an utterance.")
    }
    
    func pocketsphinxDidStopListening() {
        print("  Pocketsphinx has stopped listening.")
    }
    
    func pocketsphinxDidSuspendRecognition() {
        print("  Pocketsphinx has suspended recognition")
    }
    
    func pocketsphinxDidResumeRecognition() {
        print("  Pocketsphinx has resumed recognition")
    }
    
    func pocketsphinxDidChangeLanguageModelToFile(newLanguageModelPathAsString: String!, andDictionary newDictionaryPathAsString: String!) {
        print("  Pocketsphinx is now using the following language model: " + newLanguageModelPathAsString + " and the following dictionary: " + newDictionaryPathAsString)
    }
    
    func pocketSphinxContinuousSetupDidFailWithReason(reasonForFailure: String!) {
        print("  Listening setup wasn't successful and returned the failure reason " + reasonForFailure)
    }
    
    func pocketSphinxContinuousTeardownDidFailWithReason(reasonForFailure: String!) {
        print("  Listening teardown wasn't successful and returned with the following failure reason: " + reasonForFailure)
    }
    
    func testRecognitionCompleted() {
        print("  A test file that was submitted for recognition is now compete")
    }
    
    func pocketsphinxFailedNoMicPermissions() {
        
        NSLog("  Local callback: The user has never set mic permissions or denied permission to this app's mic, so listening will not start.")
        self.startupFailedDueToLackOfPermissions = true
        if OEPocketsphinxController.sharedInstance().isListening {
            let error = OEPocketsphinxController.sharedInstance().stopListening() // Stop listening if we are listening.
            if(error != nil) {
                NSLog("  Error while stopping listening in micPermissionCheckCompleted: %@", error)
            }
        }
    }
    
}