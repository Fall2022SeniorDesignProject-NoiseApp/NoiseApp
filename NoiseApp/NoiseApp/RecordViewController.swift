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
    @IBOutlet weak var audioIcon: UIImageView!
    @IBOutlet weak var maxDecibel: UILabel!
    @IBOutlet weak var averageDecibel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var decibel: UILabel!
    @IBOutlet weak var ProtectionRecommendation: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet var yConstraint: NSLayoutConstraint!
    // Allows us to use the audio recorder
    var audioRecorder: AVAudioRecorder!
    var levelTimer = Timer()
    var averageTimer = Timer()
    var maxDB: Float = 0.0
    var dB: Float = 0.0
    var avgDB: Float = 0.0
    var leqValues: [Float] = []
    
    // Called when this view is first loaded into memory (used for additional initialization steps)
    override func viewDidLoad()
    {
        super.viewDidLoad()
        stopRecordingButton.isEnabled = false
        //progressBar.transform = CGAffineTransform(rotationAngle: .pi / 2)
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
        self.averageTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(averageTimerCallback), userInfo: nil, repeats: true)
    }
    
    //This selector/function is called every time our timer (levelTimer) fires
    @objc func levelTimerCallback()
    {
        //we have to update meters before we can get the metering values
        audioRecorder.updateMeters()
        let dBFS = audioRecorder.averagePower(forChannel: 0)
        dB = 20 * log10(5 * powf(10, (dBFS/20)) * 160) + 11;
        decibel.text = String(format: "%.0f dB", dB)
        if (dB > maxDB) {
            maxDB = dB;
        }
        maxDecibel.text = String(format: "MAX: %.0f dB", maxDB)
        // update view based on noise level
        if (dB < 65)
        {
            UIView.animateKeyframes(withDuration: 1, delay: 1, options: [.allowUserInteraction], animations: {
                self.audioIcon.tintColor = UIColor.green
                self.ProtectionRecommendation.textColor = UIColor.init(displayP3Red: 0.392, green: 0.11, blue: 0, alpha: 0)
                }, completion: nil)
        }
        else if (65 < dB && dB < 85)
        {
            UIView.animateKeyframes(withDuration: 1, delay: 1, options: [.allowUserInteraction], animations: {
                self.audioIcon.tintColor = UIColor.yellow
                self.ProtectionRecommendation.textColor = UIColor.init(displayP3Red: 0.392, green: 0.11, blue: 0, alpha: 0)
                }, completion: nil)
        }
        else if (dB > 85)
        {
            UIView.animateKeyframes(withDuration: 1, delay: 1, options: [.allowUserInteraction], animations: {
                self.audioIcon.tintColor = UIColor.red
                self.ProtectionRecommendation.textColor = UIColor.init(displayP3Red: 0.392, green: 0.11, blue: 0, alpha: 1)
                }, completion: nil)
        }
        
        // update the progress bar to reflect the noise level; range set to [0 - 135] dB
        // whats the max that we ca record?
//        var maxdB = Float(135.0)
//        var currentdB = dB
//        progressBar.progress = currentdB / maxdB
    }
    
    @objc func averageTimerCallback()
    {
        leqValues.append(dB)
        avgDB = Float(leqValues.reduce(0.0, +)/Float(leqValues.count))
        averageDecibel.text = String(format: "AVG: %.0f dB", avgDB)
    }

    @IBAction func pressedStopRecording(_ sender: UIButton)
    {
        // Keeps the stop recording button disabled once recording has stopped
        stopRecordingButton.isEnabled = false
        recordButton.isEnabled = true
        statusLabel.text = "Tap to Record"
        decibel.text = String(format: "%.0f dB", 0)
        leqValues.removeAll()
        
        // Stops recording
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
        if (segue.identifier == "goToReferences")
        {
            let referencesVC = segue.destination as! ReferencesViewController
            // do nothing yet
        }
    }
    
    @IBAction func ReferencesButtonPressed(_ sender: UIButton)
    {
        performSegue(withIdentifier: "goToReferences", sender: self)
    }
    
    
    
}


