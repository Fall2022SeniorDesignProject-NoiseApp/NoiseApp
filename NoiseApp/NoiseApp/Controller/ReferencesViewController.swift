//
//  ReferencesViewController.swift
//  NoiseApp
//
//  Created by Mitchel Santillan Cruz on 9/14/22.
//

import UIKit

class ReferencesViewController: UIViewController
{
    @IBOutlet weak var doseReadout: UILabel!
    @IBOutlet weak var doseInput: UITextField!
    
    let link = DecibelManager.sharedInstance
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        doseReadout.isHidden = true
        doseInput.delegate = self
    }

    @IBAction func pressedOSHA(_ sender: UIButton) {
        UIApplication.shared.open(URL(string:"https://www.osha.gov/laws-regs/regulations/standardnumber/1910/1910.95")! as URL)
    }
    
    @IBAction func pressedNIOSH(_ sender: UIButton) {
        UIApplication.shared.open(URL(string:"https://www.cdc.gov/niosh/topics/noise/default.html")! as URL)
    }
    
    @IBAction func pressedHome(_ sender: UIButton)
    {
        dismiss(animated: true)
    }

    @IBAction func textFieldTapped(_ sender: UITextField) {
        doseInput.text = ""
        doseInput.becomeFirstResponder()
        doseInput.textColor = #colorLiteral(red: 0.04858401418, green: 0.1353752613, blue: 0.2516219318, alpha: 1)
    }
    
}

extension ReferencesViewController: UITextFieldDelegate {
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
