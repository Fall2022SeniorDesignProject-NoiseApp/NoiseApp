//
//  SettingsViewController.swift
//  NoiseApp
//
//  Created by Andy Hines on 10/7/22.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var standardLabel: UILabel!
    @IBOutlet weak var toggleNIOSH: UIButton!
    @IBOutlet weak var toggleOSHA: UIButton!
    var link = DecibelManager()
    static var state = "OSHA"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (SettingsViewController.state == "OSHA") {
            standardLabel.text = "OSHA Standards"
            toggleOSHA.isEnabled = false
            toggleNIOSH.isEnabled = true
        }
        else {
            standardLabel.text = "NIOSH Standards"
            toggleOSHA.isEnabled = true
            toggleNIOSH.isEnabled = false
        }
    }

    @IBAction func returnHome(_ sender: UIButton) {
            dismiss(animated: true)
    }
    
    @IBAction func oshaPressed(_ sender: UIButton) {
        standardLabel.text = "OSHA Standards"
        toggleNIOSH.isEnabled = true
        toggleOSHA.isEnabled = false
        link.setBoundHigh(number: 90)
        link.setBoundLow(number: 70)
        SettingsViewController.state = "OSHA"
    }
    
    @IBAction func nioshPressed(_ sender: UIButton) {
        standardLabel.text = "NIOSH Standards"
        toggleOSHA.isEnabled = true
        toggleNIOSH.isEnabled = false
        link.setBoundHigh(number: 85)
        link.setBoundLow(number: 65)
        SettingsViewController.state = "NIOSH"
    }
    
}
