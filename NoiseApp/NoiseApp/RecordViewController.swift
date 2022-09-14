//
//  RecordViewController.swift
//  NoiseApp
//
//  Created by Mitchel Santillan Cruz on 9/1/22.
//

import Foundation
// Default framework
import UIKit
// Framework needed to record and playback
import AVFoundation

class RecordViewController: UIViewController, AVAudioRecorderDelegate
{
    // UI elements
    @IBOutlet weak var decibel: UILabel!
    @IBOutlet weak var ProtectionRecommendation: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet var yConstraint: NSLayoutConstraint!
    // Allows us to use the audio recorder
    var audioRecorder: AVAudioRecorder!
    var levelTimer = Timer()
    
    // Called when this view is first loaded into memory (used for additional initialization steps)
    override func viewDidLoad()
    {
        super.viewDidLoad()
        stopRecordingButton.isEnabled = false
    }
    
    // Locks in app in portrait mode
    override var shouldAutorotate: Bool {return false}
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {return .portrait}
    
    @IBAction func pressedRecord(_ sender: UIButton)
    {
        // Keeps the record button disabled while already recording
        statusLabel.text = "Decibel Tracking in Progress"
        stopRecordingButton.isEnabled = true
        recordButton.isEnabled = false
                
        // Creates a file path to the recording which resides in the document directory
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        print("Your file path: \(filePath!)")

        // Creates a session needed to record/playback audio
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)

        // Preparations before recording
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        
        // Begin recording
        audioRecorder.record()
        
        self.levelTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(levelTimerCallback), userInfo: nil, repeats: true)
    }
    
    //This selector/function is called every time our timer (levelTime) fires
    @objc func levelTimerCallback()
    {
        //we have to update meters before we can get the metering values
        audioRecorder.updateMeters()
        let dBFS = audioRecorder.averagePower(forChannel: 0)
        let dB = 20 * log10(5 * powf(10, (dBFS/20)) * 160) + 10;
        decibel.text = String(format: "%.0f dB", dB)
        if (dB < 65) {
            UIView.animate(withDuration: 1) {
//                self.statusLabel.textColor = UIColor.init(displayP3Red: 1.0, green: 0.435, blue: 0.32, alpha: 1)
//                self.stopRecordingButton.tintColor = UIColor.init(displayP3Red: 1.0, green: 0.435, blue: 0.32, alpha: 1)
//                self.view.backgroundColor = UIColor.init(displayP3Red: 0.0, green: 0.4, blue: 0.0, alpha: 1)
            }
        }
        else if (65 < dB && dB < 85) {
            UIView.animate(withDuration: 1) {
//                self.statusLabel.textColor = UIColor.init(displayP3Red: 0.01, green: 0.14, blue: 0.30, alpha: 1)
//                self.stopRecordingButton.tintColor = UIColor.init(displayP3Red: 0.01, green: 0.14, blue: 0.30, alpha: 1)
//                self.view.backgroundColor = UIColor.init(displayP3Red: 0.93, green: 0.82, blue: 0.01, alpha: 1)
            }
        }
        else if (dB > 85) {
            UIView.animate(withDuration: 1) {
//                self.statusLabel.textColor = UIColor.init(displayP3Red: 0.00, green: 0.75, blue: 0.79, alpha: 1)
//                self.stopRecordingButton.tintColor = UIColor.init(displayP3Red: 0.00, green: 0.75, blue: 0.79, alpha: 1)
//                self.view.backgroundColor = UIColor.init(displayP3Red: 0.79, green: 0.04, blue: 0.0, alpha: 1)
                self.ProtectionRecommendation.textColor = UIColor.init(displayP3Red: 0.392, green: 0.11, blue: 0, alpha: 1)
            }
            
        }
    }
    
    @IBAction func pressedStopRecording(_ sender: UIButton)
    {
        // Keeps the stop recording button disabled once recording has stopped
        stopRecordingButton.isEnabled = false
        recordButton.isEnabled = true
        statusLabel.text = "Tap to Record"
        
        // Stops recording
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
        self.levelTimer.invalidate()
        self.view.backgroundColor = UIColor.init(displayP3Red: 0.01, green: 0.14, blue: 0.3, alpha: 1)
        
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
    
    
}


