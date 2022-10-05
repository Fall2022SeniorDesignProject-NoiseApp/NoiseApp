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
    // Properties
    var decibelData: DecibelData?
    var maxDB: Float = 0.0
    
    // Methods
    mutating func calculateDecibels(decibelIn: Float)
    {
        let dB = 20 * log10(5 * powf(10, (decibelIn/20)) * 160) + 11
        
        if (dB > maxDB)
        {
            maxDB = dB
        }
        
        if (dB < 65)
        {
            decibelData = DecibelData(decibel: dB, color: UIColor.green, recommendation: "")
        }
        else if (65 < dB && dB < 85)
        {
            decibelData = DecibelData(decibel: dB, color: UIColor.yellow, recommendation: "")
        }
        else if (dB > 85)
        {
            decibelData = DecibelData(decibel: dB, color: UIColor.red, recommendation: "HEARING PROTECTION RECOMMENDED")
        }        
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
}
