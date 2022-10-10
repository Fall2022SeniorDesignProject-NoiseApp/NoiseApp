//
//  DecibelManager.swift
//  NoiseApp
//
//  Created by Mitchel Santillan Cruz on 10/4/22.
//

import Foundation
import UIKit
import AVFoundation

struct DecibelManager
{
    //Andy Hines: I am developing using a remote Mac desktop so I'm unable to test the success of implementing the OSHA/NIOSH bounds. If we're having problems, it's probably because multiple controllers are creating instances of DecibelManager(). In that case we should add a static shared instance then access it from each other controller instead of creating "var link".
    // Properties
    var decibelData: DecibelData?
    var maxDB: Float = 0.0
    var boundHigh: Float = 0
    var boundLow: Float = 0
    
    // Methods
    mutating func calculateDecibels(decibelIn: Float)
    {
        let dB = 20 * log10(5 * powf(10, (decibelIn/20)) * 160) + 11
        
        if (dB > maxDB)
        {
            maxDB = dB
        }
        
        if (dB < boundLow)
        {
            decibelData = DecibelData(decibel: dB, color: UIColor.green, recommendation: "")
        }
        else if (boundLow < dB && dB < boundHigh)
        {
            decibelData = DecibelData(decibel: dB, color: UIColor.yellow, recommendation: "")
        }
        else if (dB > boundHigh)
        {
            decibelData = DecibelData(decibel: dB, color: UIColor.red, recommendation: "HEARING PROTECTION RECOMMENDED")
        }        
    }
    
    func calculateIntensity(decibelIn: Float, timeInSeconds: Float) -> Float
    {
        let intensity = powf(10, (decibelIn/10))
        let weightedIntensity = intensity * timeInSeconds
        return weightedIntensity
    }
    
    func getDecibel() -> String
    {
        // syntax means return 0.0 in case decibel is nil (null)
        return String(format: "%.0f dB", decibelData?.decibel ?? 0.0)
    }
    
    func getMaxDecibel() -> String
    {
        return String(format: "MAX: %.0f dB", maxDB)
    }
    
    func getProtectionRec() -> String
    {
        return decibelData?.recommendation ?? "N/A"
    }
    
    func getTintColor() -> UIColor
    {
        return decibelData?.color ?? UIColor.white
    }
    
    func getFilePath() -> URL
    {
        // Creates a file path to the recording which resides in the document directory
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        return filePath!
    }
    
    func beginAudioSession()
    {
        // Creates a session needed to record/playback audio
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
    }
    
    mutating func setBoundHigh(number: Float) {
        self.boundHigh = number
    }
    
    mutating func setBoundLow(number: Float) {
        self.boundLow = number
    }
}
