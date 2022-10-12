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
    @IBOutlet weak var ProtectionRecommendation: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    var levelTimer = Timer()
    var averageTimer = Timer()
    
    var maxDB: Float = 0.0
    var avgDB: Float = 0.0
    var leqValues: [Float] = []
    
    var link = DecibelManager()
    
    let shapeLayer = CAShapeLayer()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        stopRecordingButton.isEnabled = false
        configureProgressBar()
    }
    
    // Handels the circular progress bar
    func configureProgressBar()
    {
        let center = view.center
        
        // create my track layer
        let trackLayer = CAShapeLayer()
        
        let circularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        trackLayer.path = circularPath.cgPath
        
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
        view.layer.addSublayer(trackLayer)
        
        shapeLayer.path = circularPath.cgPath
        
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        
        shapeLayer.strokeEnd = 0
        
        view.layer.addSublayer(shapeLayer)
    }
    
    @IBAction func pressedRecord(_ sender: UIButton)
    {
        // Keeps the record button disabled while already recording
        stopRecordingButton.isEnabled = true
        recordButton.isEnabled = false
                
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
    
    @objc func levelTimerCallback()
    {
        audioRecorder.updateMeters()
        let dBFS = audioRecorder.averagePower(forChannel: 0)
        link.calculateDecibels(decibelIn: dBFS)

        decibel.text = link.getFormattedDecibel()
        maxDecibel.text = link.getMaxDecibel()
        ProtectionRecommendation.text = link.getProtectionRec()
                
        let dB = link.getDecibelValue()
        let normalizedValue = (dB - 0) / (115.0 - 0)
        
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        // progress bar fills up at 0.9
        basicAnimation.toValue = normalizedValue - 0.1
        
        basicAnimation.duration = 0.00001
        
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


    @IBAction func pressedStopRecording(_ sender: UIButton)
    {
        stopRecordingButton.isEnabled = false
        recordButton.isEnabled = true
        decibel.text = String(format: "%.0f dB", 0)
        leqValues.removeAll()
                
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
        self.levelTimer.invalidate()
        self.averageTimer.invalidate()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool)
    {
        // Assuming our recording saved successfully, jump to the next view
        if flag
        {
            performSegue(withIdentifier: "playRecordings", sender: audioRecorder.url)
        }
        else
        {
            print("\n Error: Could not save recording")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Makes sure to send the audio's file path to the next view
        if segue.identifier == "playRecordings"
        {
            let destinationVC = segue.destination as! PlayRecordingsViewController
            let url = sender as! URL
            destinationVC.recordedAudioURL = url
        }
    }
    
    @IBAction func ReferencesButtonPressed(_ sender: UIButton)
    {
        performSegue(withIdentifier: "goToReferences", sender: self)
    }
}

