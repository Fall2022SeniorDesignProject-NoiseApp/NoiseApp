//
//  ReferencesViewController.swift
//  NoiseApp
//
//  Created by Mitchel Santillan Cruz on 9/14/22.
//

import UIKit

class ReferencesViewController: UIViewController
{
    let link = DecibelManager.sharedInstance
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if link.isDarkMode {
            view.backgroundColor = #colorLiteral(red: 0.04705882353, green: 0.137254902, blue: 0.2509803922, alpha: 1)
        }
        else {
            view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        }
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

}
