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
    
    @IBOutlet weak var toggleENGSTD: UIButton!
    let link = DecibelManager.sharedInstance
    static var state = "OSHA"
    @IBOutlet weak var toggleHCP: UIButton!
    var tag = 0
    
    @IBOutlet weak var thresholdLabel: UILabel!
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
            standardLabel.text = "OSHA Standards Active"
            toggleOSHA.isEnabled = false
            toggleNIOSH.isEnabled = true
        }
        else
        {
            standardLabel.text = "NIOSH Standards Active"
            toggleOSHA.isEnabled = true
            toggleNIOSH.isEnabled = false
        }
        if (tag == 0)
        {
            thresholdLabel.text = "80 db Threshold Active"
            toggleENGSTD.isEnabled = true
            toggleHCP.isEnabled = false
            link.setThreshold(inputThres: 80)
        }
        else
        {
            thresholdLabel.text = "90 db Threshold Active"
            toggleHCP.isEnabled = true
            toggleENGSTD.isEnabled = false
            link.setThreshold(inputThres: 90)
        }
    }

    @IBAction func returnHome(_ sender: UIButton)
    {
            dismiss(animated: true)
    }
    
    @IBAction func oshaPressed(_ sender: UIButton)
    {
        standardLabel.text = "OSHA Standards Active"
        toggleNIOSH.isEnabled = true
        toggleOSHA.isEnabled = false
        link.setBoundLow(number: OSHA_LOWBOUND)
        link.setBoundHigh(number: OSHA_HIGHBOUND)
        SettingsViewController.state = "OSHA"
    }
    
    @IBAction func nioshPressed(_ sender: UIButton)
    {
        standardLabel.text = "NIOSH Standards Active"
        toggleOSHA.isEnabled = true
        toggleNIOSH.isEnabled = false
        link.setBoundLow(number: NIOSH_LOWBOUND)
        link.setBoundHigh(number: NIOSH_HIGHBOUND)
        SettingsViewController.state = "NIOSH"
    }
    
    @IBAction func hcpPressed(_ sender: UIButton)
    {
        thresholdLabel.text = "80 db Threshold Active"
        toggleENGSTD.isEnabled = true
        toggleHCP.isEnabled = false
        link.setThreshold(inputThres: 80)
        tag = 0
    }
    
    @IBAction func engstdPressed(_ sender: UIButton)
    {
        thresholdLabel.text = "90 db Threshold Active"
        toggleHCP.isEnabled = true
        toggleENGSTD.isEnabled = false
        link.setThreshold(inputThres: 90)
        tag = 1
    }
    
    @IBAction func colorSwitchActivated(_ sender: UISwitch)
    {
        if sender.isOn
        {
            link.setDarkMode(value: true)
        }
        else
        {
            link.setDarkMode(value: false)
        }
        setColorMode()
    }
    
    func setColorMode()
    {
        if link.isDarkMode
        {
            view.backgroundColor = #colorLiteral(red: 0.04705882353, green: 0.137254902, blue: 0.2509803922, alpha: 1)
            standardLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            thresholdLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            colorSwitch.setOn(true, animated: true)
        }
        else
        {            
            view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            standardLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            thresholdLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            colorSwitch.setOn(false, animated: true)
        }
    }
}
