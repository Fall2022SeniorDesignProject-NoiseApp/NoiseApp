//
//  RecordViewController.swift
//  NoiseApp
//
//  Created by Mitchel Santillan Cruz on 9/1/22.
//

import Foundation
import UIKit
import AVFoundation

class RecordViewController: UIViewController, AVAudioRecorderDelegate
{
    @IBOutlet weak var audioIcon: UIImageView!
    @IBOutlet weak var maxDecibel: UILabel!
    @IBOutlet weak var averageDecibel: UILabel!
    @IBOutlet weak var decibel: UILabel!
    @IBOutlet weak var ProtectionRecommendation: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    var levelTimer = Timer()
    var averageTimer = Timer()
    
    var maxDB: Float = 0.0
    var avgDB: Float = 0.0
    var leqValues: [Float] = []
    
    var link = DecibelManager()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        stopRecordingButton.isEnabled = false
    }
    
    @IBAction func pressedRecord(_ sender: UIButton)
    {
        // Keeps the record button disabled while already recording
        statusLabel.text = "Decibel Tracking in Progress"
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
        
        self.levelTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(levelTimerCallback), userInfo: nil, repeats: true)
        self.averageTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(averageTimerCallback), userInfo: nil, repeats: true)
    }
    
    @objc func levelTimerCallback()
    {
        audioRecorder.updateMeters()
        let dBFS = audioRecorder.averagePower(forChannel: 0)
        link.calculateDecibels(decibelIn: dBFS)

        decibel.text = link.getDecibel()
        maxDecibel.text = link.getMaxDecibel()
        audioIcon.tintColor = link.getTintColor()
        ProtectionRecommendation.text = link.getProtectionRec()
    }
    
    @objc func averageTimerCallback()
    {
        var db = link.decibelData?.decibel
        leqValues.append(db!)
        avgDB = Float(leqValues.reduce(0.0, +) / Float(leqValues.count))
        averageDecibel.text = String(format: "AVG: %.0f dB", avgDB)
    }

    @IBAction func pressedStopRecording(_ sender: UIButton)
    {
        stopRecordingButton.isEnabled = false
        recordButton.isEnabled = true
        statusLabel.text = "Tap to Record"
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
