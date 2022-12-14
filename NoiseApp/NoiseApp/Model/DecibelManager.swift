//
//  DecibelManager.swift
//  NoiseApp
//
//  Created by Mitchel Santillan Cruz on 10/4/22.
//

import Foundation
import UIKit
import AVFoundation

class DecibelManager
{
    // Singleton referenced in controllers
    static let sharedInstance = DecibelManager()
    
    // Properies
    let OSHA_LOWBOUND: Float = 70.0
    let OSHA_HIGHBOUND: Float = 90.0
    let NIOSH_LOWBOUND: Float = 70.0
    let NIOSH_HIGHBOUND: Float = 85.0
    
    var decibelData: DecibelData?
    var maxDB: Float = 0.0
    
    var boundLow: Float!
    var boundHigh: Float!
    var threshold = 80
    var dB: Float!
    var isDarkMode: Bool!
    
    var settingsVC: SettingsViewController!
    
    private init()
    {
        setDefaultDecibelStandard()
        setDarkMode(value: true)
    }
    
    // Methods
    func calculateDecibels(decibelIn: Float)
    {
        let dB = 20 * log10(5 * powf(15, (decibelIn/20)) * 160) + 50
        //let dB = (20 * log10(5 * powf(15, (decibelIn/20)) * 160) + 50)/2
        if (dB > maxDB)
        {
            maxDB = dB
        }
        
        if (dB <= boundLow)
        {
            decibelData = DecibelData(decibel: dB, color: UIColor.green, recommendation: "")
        }
        else if (boundLow < dB && dB < boundHigh)
        {
            decibelData = DecibelData(decibel: dB, color: UIColor.yellow, recommendation: "")
        }
        else if (dB >= boundHigh)
        {
            decibelData = DecibelData(decibel: dB, color: UIColor.red, recommendation: "HEARING PROTECTION RECOMMENDED")
        }        
    }
    
    func setDefaultDecibelStandard()
    {
        // Currently the default is the OSHA standards
        boundLow = OSHA_LOWBOUND
        boundHigh = OSHA_HIGHBOUND
    }
    
    func calculateIntensity(decibelIn: Float, timeInSeconds: Float) -> Float
    {
        let intensity = powf(10, (decibelIn/10))
        let weightedIntensity = intensity * timeInSeconds
        return weightedIntensity
    }
    
    func getFormattedDecibel() -> String
    {
        return String(format: "%.0f", decibelData?.decibel ?? 0.0)
    }
    
    func getDecibelValue() -> Float
    {
        return decibelData?.decibel ?? 0.0
    }
    
    func getMaxDecibel() -> String
    {
        return String(format: "%.0f", maxDB)
    }
    //unused
    //func getProtectionRec() -> String
    //{
    //    return decibelData?.recommendation ?? "N/A"
    //}
    
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
        try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.measurement, options: AVAudioSession.CategoryOptions.duckOthers)
    }
    
    func setBoundHigh(number: Float)
    {
        boundHigh = number
    }
    
    func setBoundLow(number: Float)
    {
        boundLow = number
    }
    
    func setThreshold(inputThres: Int)
    {
        threshold = inputThres
    }
    
    func getThreshold() -> Int
    {
        return threshold
    }
    
    func clearMaxDecibel()
    {
        maxDB = 0.0
    }
    
    func getCurrentExchangeRate() -> String
    {
        if (boundHigh == NIOSH_HIGHBOUND)
        {
            return "NIOSH"
        }
        else if (boundHigh == OSHA_HIGHBOUND)
        {
            return "OSHA"
        }
        else
        {
            return "CUSTOM"
        }
    }
    
    func maxTimeAllowed(decibelIn: Float) -> Float
    {
        return 8 / (powf(2, (decibelIn - 90) / 5))
    }
    
    func dosagePerTime(decibelIn: Float, minutes: Int, threshold: Int, exchangeRate: Int) -> Float
    {
        if (decibelIn < Float(threshold)) {
            return 0
        }
        else {
            return Float(minutes)/(60 * 8/(powf(2, (decibelIn - 90) / Float(exchangeRate))))
        }
    }
    
    func dosagePerTimeWithProtection(decibelIn: Float, minutes: Int, NRR: Int, threshold: Int, exchangeRate: Int) -> Float
    {
        let adjustedDecibel: Float = decibelIn - 90.0
        let adjustedNRR: Float = (Float(NRR) - 7.0)/2.0
        let exponent = adjustedDecibel - adjustedNRR
        if (decibelIn < Float(threshold)) {
            return 0
        }
        else {
            return Float(minutes)/(60 * 8/(powf(2, Float(exponent/Float(exchangeRate)))))

        }
    }
    
    func setDarkMode(value: Bool)
    {
        isDarkMode = value
    }
}
