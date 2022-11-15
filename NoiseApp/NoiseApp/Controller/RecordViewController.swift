//
//  RecordViewController.swift
//  NoiseApp
//
//  Created by Mitchel Santillan Cruz on 9/1/22.
//

import Foundation
import UIKit
import AVFoundation
import SwiftUI
import AudioToolbox

class RecordViewController: UIViewController, AVAudioRecorderDelegate
{
    @IBOutlet weak var maxDecibel: UILabel!
    @IBOutlet weak var decibel: UILabel!
    @IBOutlet weak var averageDecibel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var sessionTimer: UILabel!
    @IBOutlet weak var dosageButton: UIButton!
    @IBOutlet weak var saveSessionButton: UIButton!
    @IBOutlet weak var alertCurrent: UILabel!
    @IBOutlet weak var alertSession: UILabel!
    
    @IBOutlet weak var dbLabel: UILabel!
    var shapeLayer = CAShapeLayer()
    let REFRESH_RATE = 0.00001
    let OFFSET: Float = 0.1    
    
    var audioRecorder: AVAudioRecorder!
    var levelTimer = Timer()
    var vibrateTimer = Timer()
    var averageTimer = Timer()    
    var sessionLengthTimer = Timer()
    var basicAnimation: CABasicAnimation!
    var exceededThreshold = false
    var dB: Float = 0.0
    var maxDB: Float = 0.0
    var avgDB: Float = 0.0
    var saved = false
    var sessionIdentifier = 0
    var sessionLength: Float = 0.00
    var leqValues: [Float] = []
    let link = DecibelManager.sharedInstance
    let screenSize: CGRect = UIScreen.main.bounds
    
    // Runs the first time the app is loaded into memory
    override func viewDidLoad()
    {
        super.viewDidLoad()
        resetButton.isEnabled = false
        // Sets the default color to light mode
        link.isDarkMode = false
        (screenSize.height >= 700) ? configureProgressBar() : print("disabled progress bar (screen is too small)")
        saveSessionButton.isEnabled = false
        alertCurrent.isHidden = true
        alertSession.isHidden = true
//        print("Your screen size: \(screenSize)")
//        print("Your screen size width: \(screenSize.width)")
//        print("Your screen size height: \(screenSize.height)")
    }
    
    // Runs every time this views appears on screen
    override func viewWillAppear(_ animated: Bool)
    {
        maxDB = (link.getCurrentExchangeRate() == "OSHA") ? 90.0 : 85.0
        setColorMode()
        if (!resetButton.isEnabled)
        {
            shapeLayer.strokeColor = view.backgroundColor!.cgColor
        }
    }
    
    func setColorMode()
    {
        if link.isDarkMode
        {
            view.backgroundColor = #colorLiteral(red: 0.07450980392, green: 0.2431372549, blue: 0.4549019608, alpha: 1)
            //decibel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            maxDecibel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            averageDecibel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            sessionTimer.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        else
        {
            view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            //decibel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            maxDecibel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            averageDecibel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            sessionTimer.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        
    }
    
    // Handles the circular progress bar
    func configureProgressBar()
    {
        let center = view.center
        
        // create my track layer
        let trackLayer = CAShapeLayer()
        
        let circularPath = UIBezierPath(arcCenter: center, radius: 150, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        trackLayer.path = circularPath.cgPath
                
        trackLayer.strokeColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
        view.layer.addSublayer(trackLayer)
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.lineWidth = 10
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        
        shapeLayer.strokeEnd = 0
        
        view.layer.addSublayer(shapeLayer)
    }
    
    // rename this method and the UIButton
    @IBAction func pressedActionBtn(_ sender: UIButton)
    {
        resetButton.isEnabled = true
        alertSession.isHidden = (exceededThreshold) ? false : true
        if (actionButton.tag == 0)
        {
            resetButton.isEnabled = true
            // begin recording
            let symbol = UIImage(systemName: "pause.circle")
            actionButton.setImage(symbol, for: .normal)
            actionButton.tag = 1
            
            let filePath = link.getFilePath()
            link.beginAudioSession()

            // Preparations before recording
            try! audioRecorder = AVAudioRecorder(url: filePath, settings: [:])
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            
            sessionLengthTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(sessionTimerCallback), userInfo: nil, repeats: true)
            levelTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(levelTimerCallback), userInfo: nil, repeats: true)
            averageTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(averageTimerCallback), userInfo: nil, repeats: true)
        }
        else
        {
            let symbol = UIImage(systemName: "record.circle")            
            actionButton.setImage(symbol, for: .normal)
            actionButton.tag = 0
            pauseRecording()
        }
    }
    
    func monitorDecibels()
    {
        dB = link.getDecibelValue()
        if (dB >= link.boundHigh)
        {
            //let dB = link.getMaxDecibel()
            //let msg = "\(dB) is a dangerous dB level, consider using hearing protection."
            //let popup = UIAlertController(title: link.getProtectionRec(), message: msg, preferredStyle: .alert)
            //let dismiss = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            
            //popup.addAction(dismiss)
            //present(popup, animated: true)
            exceededThreshold = true
            alertSession.isHidden = false
            alertCurrent.isHidden = false
        }
        else
        {
            alertCurrent.isHidden = true
        }
        
    }
        
    @objc func levelTimerCallback()
    {
        audioRecorder.updateMeters()
        let dBFS = audioRecorder.averagePower(forChannel: 0)
        link.calculateDecibels(decibelIn: dBFS)

        decibel.text = link.getFormattedDecibel()
        maxDecibel.text = link.getMaxDecibel()
        monitorDecibels()
                
        let dB = link.getDecibelValue()
        let normalizedValue = (dB - 0) / (maxDB - 0)
        
        basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        // progress bar fills up at 0.9
        basicAnimation.toValue = normalizedValue - OFFSET
        
        basicAnimation.duration = REFRESH_RATE
        
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        
        shapeLayer.add(basicAnimation, forKey: "urSoBasic")
                
        if (dB > maxDB)
        {
            shapeLayer.strokeColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            dbLabel.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            decibel.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(vibrateOnQueue), userInfo: nil, repeats: false)
        }
        else
        {
            shapeLayer.strokeColor = #colorLiteral(red: 0, green: 0.4823529412, blue: 0.3098039216, alpha: 1)
            dbLabel.textColor = #colorLiteral(red: 0, green: 0.4823529412, blue: 0.3098039216, alpha: 1)
            decibel.textColor = #colorLiteral(red: 0, green: 0.4823529412, blue: 0.3098039216, alpha: 1)        }
    }
    
    @objc func vibrateOnQueue()
    {
        audioRecorder.stop()
        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { }
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    @objc func averageTimerCallback()
    {
        let db = link.decibelData?.decibel
        let weightedIntensity = link.calculateIntensity(decibelIn: db!, timeInSeconds: 2.0)
        leqValues.append(weightedIntensity)
        let twa = Float(leqValues.reduce(0.0, +) / (Float(leqValues.count) * 2))
        avgDB = 10 * log10(twa)
        averageDecibel.text = String(format: "%.0f", avgDB)
        saveSessionButton.isEnabled = true
    }
    
    @objc func sessionTimerCallback()
    {
        sessionLength += 0.01
        sessionTimer.text = String(format: "%.0f", sessionLength)
    }
    
    func resetReadings()
    {
        decibel.text = String(format: "00")
        maxDecibel.text = String(format: "00")
        averageDecibel.text = String(format: "00")
        alertSession.isHidden = true
        link.clearMaxDecibel()
    }
    
    func resetRecording()
    {
        resetButton.isEnabled = false
        actionButton.isEnabled = true
        leqValues.removeAll()
        exceededThreshold = false
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
        self.levelTimer.invalidate()
        self.averageTimer.invalidate()
        self.sessionLengthTimer.invalidate()
        self.sessionTimer.text = "0"
        sessionLength = 0.00
    }
    
    @IBAction func saveButtonPressed()
    {
        let msg = "Save Session?"
        let popup = UIAlertController(title: msg, message: "", preferredStyle: .actionSheet)
        let saveAction = UIAlertAction(
            title: "Yes",
            style: .default) { [self] (action) in
                self.performSegue(withIdentifier: "goToDosage", sender: sessionIdentifier)
        }
        let saveOptionRejected = UIAlertAction(title: "No", style: .default, handler: nil)
        
        popup.addAction(saveAction)
        popup.addAction(saveOptionRejected)
        present(popup, animated: true)
        saved = true
    }
    
    func pauseRecording()
    {
        actionButton.isEnabled = true
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
        self.levelTimer.invalidate()
        self.averageTimer.invalidate()
        self.sessionLengthTimer.invalidate()
        
        // clear the reset the progress bar below
    }
    
    @IBAction func ResetButtonPressed(_ sender: UIButton)
    {
        self.vibrateTimer.invalidate()
        resetRecording()
        resetReadings()
        let symbol = UIImage(systemName: "record.circle")
        actionButton.setImage(symbol, for: .normal)
        actionButton.tag = 0
        saveSessionButton.isEnabled = false
        shapeLayer.strokeColor = view.backgroundColor!.cgColor
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "goToDosage"
        {
            let destinationVC = segue.destination as! DosageViewController
            if (saved == true) {
                destinationVC.currentSessionLEQ = avgDB
                destinationVC.currentSessionLength = sessionLength
            }
        }
    }
    
    @IBAction func ReferencesButtonPressed(_ sender: UIButton)
    {
        performSegue(withIdentifier: "goToReferences", sender: self)
    }
    
    
//    @IBAction func exitedSettings(_ sender: UIButton)
//    {
//        setColorMode()
//    }
}
