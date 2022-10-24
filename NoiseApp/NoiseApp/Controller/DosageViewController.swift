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
    @IBOutlet weak var doseInput: UITextField!
    @IBOutlet weak var doseReadout: UILabel!
    
    var currentSessionLength: Float! = nil
    var currentSessionLEQ: Float! = nil
    var currentSessionIdentifier: Int! = nil
    
    let link = DecibelManager.sharedInstance
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        doseReadout.isHidden = true
        doseInput.delegate = self
    }

    @IBAction func returnHome(_ sender: UIButton)
    {
            dismiss(animated: true)
    }
    
    @IBAction func textFieldTapped(_ sender: UITextField) {
        doseInput.text = ""
        doseInput.becomeFirstResponder()
        doseInput.textColor = #colorLiteral(red: 0.04858401418, green: 0.1353752613, blue: 0.2516219318, alpha: 1)
    }
}

extension DosageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let input = Float(textField.text!) ?? 0
        let doseIn = link.maxTimeAllowed(decibelIn: input)
        let dosage = round(doseIn * 10) / 10
        let dosagePrecise = round(doseIn * 100) / 100
        if (doseIn >= 24.0) {
            doseReadout.text = "At \(input) dB without hearing protection, you will not reach your maximum daily dosage within the next 24 hours."
        }
        else if (doseIn <= 0.0) {
            doseReadout.text = "At \(input) dB without hearing protection, you will be exposed to your maximum daily noise dosage immediately."
        }
        else if (doseIn < 10.0) {
            doseReadout.text = "At \(input) dB without hearing protection, you will be exposed to your maximum daily noise dosage in \(dosagePrecise) hours."
        }
        else {
            doseReadout.text = "At \(input) dB without hearing protection, you will be exposed to your maximum daily noise dosage in \(dosage) hours."
        }
        doseReadout.isHidden = false
        textField.resignFirstResponder()
        return true
    }
}

