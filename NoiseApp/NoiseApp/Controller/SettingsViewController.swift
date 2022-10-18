//
//  SettingsViewController.swift
//  NoiseApp
//
//  Created by Andy Hines on 10/7/22.
//

import UIKit

class SettingsViewController: UIViewController
{
    @IBOutlet weak var standardLabel: UILabel!
    @IBOutlet weak var toggleNIOSH: UIButton!
    @IBOutlet weak var toggleOSHA: UIButton!
    
    let OSHA_LOWBOUND: Float = 70.0
    let OSHA_HIGHBOUND: Float = 90.0
    let NIOSH_LOWBOUND: Float = 70.0
    let NIOSH_HIGHBOUND: Float = 85.0    
    
    let link = DecibelManager.sharedInstance
    static var state = "OSHA"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        configureView()
    }
    
    func configureView()
    {
        // Sets OSHA as the default standard
        if (SettingsViewController.state == "OSHA")
        {
            standardLabel.text = "OSHA Guidelines"
            toggleOSHA.isEnabled = false
            toggleNIOSH.isEnabled = true
        }
        else
        {
            standardLabel.text = "NIOSH Guidelines"
            toggleOSHA.isEnabled = true
            toggleNIOSH.isEnabled = false
        }
    }

    @IBAction func returnHome(_ sender: UIButton)
    {
            dismiss(animated: true)
    }
    
    @IBAction func oshaPressed(_ sender: UIButton)
    {
        standardLabel.text = "OSHA Standards"
        toggleNIOSH.isEnabled = true
        toggleOSHA.isEnabled = false
        link.setBoundLow(number: OSHA_LOWBOUND)
        link.setBoundHigh(number: OSHA_HIGHBOUND)
        SettingsViewController.state = "OSHA"
    }
    
    @IBAction func nioshPressed(_ sender: UIButton)
    {
        standardLabel.text = "NIOSH Standards"
        toggleOSHA.isEnabled = true
        toggleNIOSH.isEnabled = false
        link.setBoundLow(number: NIOSH_LOWBOUND)
        link.setBoundHigh(number: NIOSH_HIGHBOUND)
        SettingsViewController.state = "NIOSH"
    }
}
