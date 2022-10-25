//
//  ReferencesViewController.swift
//  NoiseApp
//
//  Created by Mitchel Santillan Cruz on 9/14/22.
//

import UIKit

class ReferencesViewController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
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
