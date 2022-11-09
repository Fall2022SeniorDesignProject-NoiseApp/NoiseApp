//
//  DosageViewController.swift
//  NoiseApp
//
//  Created by Jacob Blair on 10/20/22.
//

import Foundation
import UIKit
import AVFoundation
import SwiftUI

class DosageViewController: UIViewController, AVAudioRecorderDelegate
{
//    @IBOutlet weak var doseInput: UITextField!
//    @IBOutlet weak var doseReadout: UILabel!
    @IBOutlet weak var hearingProtection: UITextField!
    @IBOutlet weak var sessionLEQ: UITextField!
    @IBOutlet weak var sessionLength: UITextField!
    @IBOutlet weak var totalLength: UITextField!
    @IBOutlet weak var maximumSafeTime: UITextField!
    @IBOutlet weak var percentDosage: UITextField!
    @IBOutlet weak var previousSessionButton: UIButton!
    @IBOutlet weak var nextSessionButton: UIButton!
    @IBOutlet weak var RecHearProt: UITextField!
    @IBOutlet weak var toggleProtectionEffect: UIButton!
    @IBOutlet weak var midDisplay: UIView!
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var exchangeRateLabel: UILabel!
    @IBOutlet weak var bottomDisplay: UIView!
    var currentSessionLength: Float! = nil
    var currentSessionLEQ: Float! = nil
    var currentSessionIdentifier: Int! = nil
    var isProtectionOn = false
    var sessionHasBeenSaved = false
    let userDefault = UserDefaults.standard
    
    var exchangeRate = 3
    var currentSessionIndex = 0
    var archivedSessions: Data!
    var latestSession: soundSession!
    
    private var savedSessions = [soundSession]()
    
    let link = DecibelManager.sharedInstance
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        maximumSafeTime.textColor = #colorLiteral(red: 0.8983239532, green: 0.8976963162, blue: 0.9152712822, alpha: 1)
        percentDosage.textColor = #colorLiteral(red: 0.8983239532, green: 0.8976963162, blue: 0.9152712822, alpha: 1)
//        doseReadout.isHidden = true
//        doseInput.delegate = self
        if (link.getCurrentExchangeRate() == "OSHA")
        {
            exchangeRate = 5
            exchangeRateLabel.text = "Current Exchange Rate:  5(OSHA)"
        }
        else if (link.getCurrentExchangeRate() == "NIOSH")
        {
            exchangeRate = 3
            exchangeRateLabel.text = "Current Exchange Rate:  3(NIOSH)"
        }
        if link.isDarkMode {
            view.backgroundColor = #colorLiteral(red: 0.07450980392, green: 0.2431372549, blue: 0.4549019608, alpha: 1)
            midDisplay.backgroundColor = #colorLiteral(red: 0.07450980392, green: 0.2431372549, blue: 0.4549019608, alpha: 1)
        }
        else {
            view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            midDisplay.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            bottomDisplay.backgroundColor = #colorLiteral(red: 0.07348891348, green: 0.2447949052, blue: 0.4540714025, alpha: 1)
            percentDosage.backgroundColor = #colorLiteral(red: 0.07348891348, green: 0.2447949052, blue: 0.4540714025, alpha: 1)
            maximumSafeTime.backgroundColor = #colorLiteral(red: 0.07348891348, green: 0.2447949052, blue: 0.4540714025, alpha: 1)
            RecHearProt.backgroundColor = #colorLiteral(red: 0.07348891348, green: 0.2447949052, blue: 0.4540714025, alpha: 1)


        }
        importSession()
        if (userDefault.value(forKey: "savedSessions") != nil) {
            let data = UserDefaults.standard.object(forKey: "savedSessions") as? Data
            savedSessions = try! JSONDecoder().decode([soundSession].self, from: data!)
        }
        else {
            resetButton.isEnabled = false
        }
    }
    
    func importSession() {
        if currentSessionLength ?? 0.0 > 2.0 {
            sessionLEQ.text = String(format: "%.0f", currentSessionLEQ)
            hearingProtection.text = String("0")
            sessionLength.text = String(format: "%.2f", currentSessionLength)
            maxTimeAllowed()
        }
        totalLength.text = "0.0"
    }
    
    func clearAll() {
        sessionLEQ.text = ""
        hearingProtection.text = ""
        sessionLength.text = ""
        totalLength.text = ""
        percentDosage.text = ""
        maximumSafeTime.text = ""
    }
    
    func maxTimeAllowed() {
        let input = Float(sessionLEQ.text ?? "0.0")
        //?? Float(textField.text!)
        let doseIn = link.maxTimeAllowed(decibelIn: input ?? 0.0)
        let dosage = round(doseIn * 10) / 10
        let dosagePrecise = round(doseIn * 100) / 100
        if (doseIn >= 24.0) {
            maximumSafeTime.text = "24+ Hours. You are safe."
        }
        else if (doseIn <= 0.0) {
            maximumSafeTime.text = "0 Hours. DANGER."
        }
        else if (doseIn < 10.0) {
            maximumSafeTime.text = "\(dosagePrecise) HOURS"
        }
        else {
            maximumSafeTime.text = "\(dosage) HOURS"
        }
    }
    
    func sessionPercentDosage(isProtectionOn: Bool) {
        let timeInput = Float(totalLength.text ?? "0") ?? 0.0
        if isProtectionOn == false || Int(hearingProtection.text!) == 0 {
            if timeInput > 0.0 {
                let doseIn = link.dosagePerTime(decibelIn: Float(sessionLEQ.text ?? "0") ?? 0.0, minutes: Int(totalLength.text ?? "0") ?? 0, threshold: link.getThreshold(), exchangeRate: exchangeRate)
                let processedDoseIn = doseIn * 100
                percentDosage.text = String(format: "%.2f", processedDoseIn)
            }
            else {
                percentDosage.text = "Total Time Not Given"
            }
        }
        else if isProtectionOn == true {
            if timeInput > 0.0 {
                let doseIn = link.dosagePerTimeWithProtection(decibelIn: Float(sessionLEQ.text ?? "0") ?? 0.0, minutes: Int(totalLength.text ?? "0") ?? 0, NRR: Int(hearingProtection.text ?? "0") ?? 0, threshold: link.getThreshold(), exchangeRate: exchangeRate)
                let processedDoseIn = doseIn * 100
                percentDosage.text = String(format: "%.2f", processedDoseIn)
            }
            else {
                percentDosage.text = "Total Time Not Given"
            }
        }
        
    }

    
    func updateAllOutputs(isProtectionOn: Bool) {
        maxTimeAllowed()
        sessionPercentDosage(isProtectionOn: isProtectionOn)
    }

    @IBAction func returnHome(_ sender: UIButton)
    {
            dismiss(animated: true)
            print(savedSessions)
        if let encoded = try? JSONEncoder().encode(savedSessions) {
            UserDefaults.standard.set(encoded, forKey: "savedSessions")
            print(encoded)
        }
        

//        // Retrieve from UserDefaults
//        if let data = UserDefaults.standard.object(forKey: UserDefaultsKeys.jobCategory.rawValue) as? Data,
//           let category = try? JSONDecoder().decode(JobCategory.self, from: data) {
//             print(category.name)
//        }
//            try? archivedSessions = NSKeyedArchiver.archivedData(withRootObject: savedSessions, requiringSecureCoding: false)
//            userDefault.set(archivedSessions, forKey: "savedSessions")
//            print(archivedSessions)
    }
    
    @IBAction func textFieldTapped(_ sender: UITextField) {
        sender.text = ""
        sender.becomeFirstResponder()
        sender.textColor = #colorLiteral(red: 0.8983239532, green: 0.8976963162, blue: 0.9152712822, alpha: 1)
    }
    
    @IBAction func textEditingEnded(_ sender: UITextField) {
        sender.resignFirstResponder()
        sessionHasBeenSaved = false
        if toggleProtectionEffect.tag == 0 {
            updateAllOutputs(isProtectionOn: false)
        }
        else if toggleProtectionEffect.tag == 1 {
            updateAllOutputs(isProtectionOn: true)
        }
        
    }
    
    @IBAction func pressedToggleButton(_ sender: UIButton)
    {
        if (toggleProtectionEffect.tag == 0)
        {
            toggleProtectionEffect.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.3960784314, blue: 0.1333333333, alpha: 1)
            toggleProtectionEffect.tag = 1
            updateAllOutputs(isProtectionOn: true)
            isProtectionOn = true
        }
        else
        {
            toggleProtectionEffect.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            toggleProtectionEffect.tag = 0
            updateAllOutputs(isProtectionOn: false)
            isProtectionOn = false
        }
    }
    
    @IBAction func pressedResetButton(_ sender: UIButton)
    {
        UserDefaults.standard.removeObject(forKey: "savedSessions")
        savedSessions.removeAll()
        resetButton.isEnabled = false
        clearAll()
    }
    
    
    
    @IBAction func pressedSaveButton(_ sender: UIButton)
    {
        if (sessionHasBeenSaved == false)
        {
            let session = soundSession(LEQ: Float(sessionLEQ.text!)!, sessionTime: Float(sessionLength.text ?? "0") ?? 0.0, totalTime: Int(totalLength.text!)!, isProtectionOn: isProtectionOn, protectionNRR: Int(hearingProtection.text!)!, index: currentSessionIndex)
            savedSessions.append(session)
            sessionHasBeenSaved = true
            clearAll()
            nextSessionButton.isEnabled = true
            previousSessionButton.isEnabled = true
            latestSession = savedSessions[savedSessions.count - 1]
            currentSessionIndex += 1
            resetButton.isEnabled = true
        }
        else {
            print("Session has already been saved")
        }

        }
    
    @IBAction func toggleNextSession(_ sender: UIButton)
    {
        if (savedSessions.count >= 1 && latestSession.index + 1 < savedSessions.count)
        {
            let session = savedSessions[latestSession.index + 1]
            sessionLEQ.text = String(session.LEQ)
            hearingProtection.text = String(session.protectionNRR)
            sessionLength.text = String(session.sessionTime)
            totalLength.text = String(session.totalTime)
            updateAllOutputs(isProtectionOn: isProtectionOn)
            latestSession = session
        }
        else {
            nextSessionButton.isEnabled = false
        }

        }
    
    @IBAction func toggleLastSession(_ sender: UIButton)
    {
        if (savedSessions.count >= 1 && latestSession.index >= 0)
        {
            
            let session = savedSessions[latestSession.index]
            sessionLEQ.text = String(session.LEQ)
            hearingProtection.text = String(session.protectionNRR)
            sessionLength.text = String(session.sessionTime)
            totalLength.text = String(session.totalTime)
            updateAllOutputs(isProtectionOn: isProtectionOn)
            if (latestSession.index - 1 >= 0) {
                latestSession = savedSessions[latestSession.index - 1]
            }
        }
        else {
            previousSessionButton.isEnabled = false
        }

        }

    
    
    }



struct soundSession: Codable {
    var LEQ = Float()
    var sessionTime = Float()
    var totalTime = Int()
    var isProtectionOn = Bool()
    var protectionNRR = Int()
    var index = Int()
}




