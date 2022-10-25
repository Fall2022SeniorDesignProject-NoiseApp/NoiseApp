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
    @IBOutlet weak var toggleProtectionEffect: UIButton!
    
    var currentSessionLength: Float! = nil
    var currentSessionLEQ: Float! = nil
    var currentSessionIdentifier: Int! = nil
    
    let link = DecibelManager.sharedInstance
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
//        doseReadout.isHidden = true
//        doseInput.delegate = self
        importSession()
    }
    
    func importSession() {
        if currentSessionLength > 2.0 {
            sessionLEQ.text = String(format: "%.0f", currentSessionLEQ)
            hearingProtection.text = String("0")
            sessionLength.text = String(format: "%.2f", currentSessionLength)
            maxTimeAllowed()
        }
        totalLength.text = "0.0"
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
        let soundInput = Float(sessionLEQ.text ?? "0")
        let timeInput = Float(totalLength.text ?? "0")
        if isProtectionOn == false {
            if timeInput! > 0.0 {
                let doseIn = link.dosagePerTime(decibelIn: soundInput!, minutes: Int(timeInput!))
                let processedDoseIn = doseIn * 100
                percentDosage.text = String(format: "%.2f", processedDoseIn)
            }
            else {
                percentDosage.text = "Total Time Not Given"
            }
        }
        else if isProtectionOn == true {
            if timeInput! > 0.0 {
                let doseIn = link.dosagePerTimeWithProtection(decibelIn: soundInput!, minutes: Int(timeInput!), NRR: Int(hearingProtection.text!)!)
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
    }
    
    @IBAction func textFieldTapped(_ sender: UITextField) {
        sender.text = ""
        sender.becomeFirstResponder()
        sender.textColor = #colorLiteral(red: 0.8983239532, green: 0.8976963162, blue: 0.9152712822, alpha: 1)
    }
    
    @IBAction func textEditingEnded(_ sender: UITextField) {
        sender.resignFirstResponder()
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
            
        }
        else
        {
            toggleProtectionEffect.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            toggleProtectionEffect.tag = 0
            updateAllOutputs(isProtectionOn: false)
        }
    }
}

//extension DosageViewController: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        let input = Float(textField.text!) ?? 0
//        let doseIn = link.maxTimeAllowed(decibelIn: input)
//        let dosage = round(doseIn * 10) / 10
//        let dosagePrecise = round(doseIn * 100) / 100
//        if (doseIn >= 24.0) {
//            doseReadout.text = "At \(input) dB without hearing protection, you will not reach your maximum daily dosage within the next 24 hours."
//        }
//        else if (doseIn <= 0.0) {
//            doseReadout.text = "At \(input) dB without hearing protection, you will be exposed to your maximum daily noise dosage immediately."
//        }
//        else if (doseIn < 10.0) {
//            doseReadout.text = "At \(input) dB without hearing protection, you will be exposed to your maximum daily noise dosage in \(dosagePrecise) hours."
//        }
//        else {
//            doseReadout.text = "At \(input) dB without hearing protection, you will be exposed to your maximum daily noise dosage in \(dosage) hours."
//        }
//        doseReadout.isHidden = false
//        textField.resignFirstResponder()
//        return true
//    }
    

//}

