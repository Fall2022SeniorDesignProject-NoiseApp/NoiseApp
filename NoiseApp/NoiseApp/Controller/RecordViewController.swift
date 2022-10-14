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

class RecordViewController: UIViewController, AVAudioRecorderDelegate
{
    @IBOutlet weak var maxDecibel: UILabel!
    @IBOutlet weak var decibel: UILabel!
    @IBOutlet weak var averageDecibel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
        
    let shapeLayer = CAShapeLayer()
    let REFRESH_RATE = 0.00001
    let OFFSET: Float = 0.1
    let MIN_DB: Float = 0
    let MAX_DB: Float = 115
    
    var audioRecorder: AVAudioRecorder!
    var levelTimer = Timer()
    var averageTimer = Timer()
    var maxDB: Float = 0.0
    var avgDB: Float = 0.0
    var leqValues: [Float] = []
    let link = DecibelManager.sharedInstance
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        configureProgressBar()
    }
    
    // Handels the circular progress bar
    func configureProgressBar()
    {
        let center = view.center
        
        // create my track layer
        let trackLayer = CAShapeLayer()
        
        let circularPath = UIBezierPath(arcCenter: center, radius: 135, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        trackLayer.path = circularPath.cgPath
                
        trackLayer.strokeColor = #colorLiteral(red: 0.04858401418, green: 0.1353752613, blue: 0.2516219318, alpha: 1)
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
        view.layer.addSublayer(trackLayer)
        
        shapeLayer.path = circularPath.cgPath
        
        shapeLayer.strokeColor = #colorLiteral(red: 0.9490196078, green: 0.3960784314, blue: 0.1333333333, alpha: 1)
        shapeLayer.lineWidth = 10
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        
        shapeLayer.strokeEnd = 0
        
        view.layer.addSublayer(shapeLayer)
    }
    
    // rename this method and the UIButton
    @IBAction func pressedActionBtn(_ sender: UIButton)
    {
        if (actionButton.tag == 0)
        {
            // begin recording
            resetReadings()
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
            
            levelTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(levelTimerCallback), userInfo: nil, repeats: true)
            averageTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(averageTimerCallback), userInfo: nil, repeats: true)
        }
        else
        {
            // end recording
            let symbol = UIImage(systemName: "record.circle")
            actionButton.setImage(symbol, for: .normal)
            actionButton.tag = 0
            endRecording()
        }
    }
    
    func monitorDecibels()
    {
        let dB = link.getDecibelValue()
        if (dB >= link.boundHigh)
        {
            let dB = link.getMaxDecibel()
            let msg = "\(dB) is a dangerous dB level, consider using hearing protection."
            let popup = UIAlertController(title: link.getProtectionRec(), message: msg, preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            
            popup.addAction(dismiss)
            present(popup, animated: true)
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
        let normalizedValue = (dB - MIN_DB) / (MAX_DB - MIN_DB)
        
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        // progress bar fills up at 0.9
        basicAnimation.toValue = normalizedValue - OFFSET
        
        basicAnimation.duration = REFRESH_RATE
        
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        
        shapeLayer.add(basicAnimation, forKey: "urSoBasic")
    }
    
    @objc func averageTimerCallback()
    {
        let db = link.decibelData?.decibel
        let weightedIntensity = link.calculateIntensity(decibelIn: db!, timeInSeconds: 2.0)
        leqValues.append(weightedIntensity)
        let twa = Float(leqValues.reduce(0.0, +) / (Float(leqValues.count) * 2))
        let avgDB = 10 * log10(twa)
        averageDecibel.text = String(format: "%.0f", avgDB)
    }
    
    func resetReadings()
    {
        decibel.text = String(00)
        maxDecibel.text = String(00)
        averageDecibel.text = String(00)
        link.clearMaxDecibel()
    }
    
    func endRecording()
    {
        actionButton.isEnabled = true
        leqValues.removeAll()
                
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
        self.levelTimer.invalidate()
        self.averageTimer.invalidate()
        
        // clear the reset the progress bar below
    }
    
//    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool)
//    {
//        // Assuming our recording saved successfully, jump to the next view
//        if flag
//        {
//            performSegue(withIdentifier: "playRecordings", sender: audioRecorder.url)
//        }
//        else
//        {
//            print("\n Error: Could not save recording")
//        }
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
//    {
//        // Makes sure to send the audio's file path to the next view
//        if segue.identifier == "playRecordings"
//        {
//            let destinationVC = segue.destination as! PlayRecordingsViewController
//            let url = sender as! URL
//            destinationVC.recordedAudioURL = url
//        }
//    }
    
    @IBAction func ReferencesButtonPressed(_ sender: UIButton)
    {
        performSegue(withIdentifier: "goToReferences", sender: self)
    }
}
