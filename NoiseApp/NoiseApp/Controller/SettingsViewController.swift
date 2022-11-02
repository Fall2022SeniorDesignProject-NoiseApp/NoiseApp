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
    @IBOutlet weak var colorSwitch: UISwitch!
    
    let OSHA_LOWBOUND: Float = 70.0
    let OSHA_HIGHBOUND: Float = 90.0
    let NIOSH_LOWBOUND: Float = 70.0
    let NIOSH_HIGHBOUND: Float = 85.0    
    
    let link = DecibelManager.sharedInstance
    static var state = "OSHA"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setColorMode()
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
    
    @IBAction func colorSwitchActivated(_ sender: UISwitch)
    {
        if sender.isOn {
            link.setDarkMode(value: true)
        }
        else {
            link.setDarkMode(value: false)
        }
        setColorMode()
    }
    
    func setColorMode()
    {
        if link.isDarkMode {
            view.backgroundColor = #colorLiteral(red: 0.04705882353, green: 0.137254902, blue: 0.2509803922, alpha: 1)
            standardLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            colorSwitch.setOn(true, animated: false)
        }
        else {
            view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            standardLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            colorSwitch.setOn(false, animated: false)
        }
    }
}
