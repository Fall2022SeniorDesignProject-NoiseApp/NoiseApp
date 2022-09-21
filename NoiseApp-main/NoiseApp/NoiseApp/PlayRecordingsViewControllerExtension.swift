//
//  PlayRecordingsViewControllerExtension.swift
//  NoiseApp
//
//  Created by Mitchel Santillan Cruz on 9/1/22.
//

import Foundation
import UIKit
import AVFoundation

extension PlayRecordingsViewController: AVAudioPlayerDelegate
{
    // MARK: Alerts
    
    struct Alerts
    {
        static let DismissAlert = "Dismiss"
        static let RecordingDisabledTitle = "Recording Disabled"
        static let RecordingDisabledMessage = "You've disabled this app from recording your microphone. Check Settings."
        static let RecordingFailedTitle = "Recording Failed"
        static let RecordingFailedMessage = "Something went wrong with your recording."
        static let AudioRecorderError = "Audio Recorder Error"
        static let AudioSessionError = "Audio Session Error"
        static let AudioRecordingError = "Audio Recording Error"
        static let AudioFileError = "Audio File Error"
        static let AudioEngineError = "Audio Engine Error"
    }
    
    // MARK: PlayingState
    
    enum PlayingState { case playing, notPlaying }
    
    // MARK: Audio Functions
    
    func setupAudio()
    {
        // initialize (recording) audio file
        do
        {
            audioFile = try AVAudioFile(forReading: recordedAudioURL as URL)
        }
        catch
        {
            showAlert(Alerts.AudioFileError, message: String(describing: error))
        }
    }
    
    func playSound(rate: Float? = nil)
    {
        
        // Initialize audio engine components
        audioEngine = AVAudioEngine()
        
        // Node for playing audio
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        // Node for adjusting rate
        let changeRateNode = AVAudioUnitTimePitch()
        if let rate = rate {
            changeRateNode.rate = rate
        }
        audioEngine.attach(changeRateNode)
        
        // Connect nodes
        connectAudioNodes(audioPlayerNode, changeRateNode, audioEngine.outputNode)
        
        // Schedule to play and start the engine!
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile, at: nil)
        {
            var delayInSeconds: Double = 0
            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTime(forNodeTime: lastRenderTime)
            {
                if let rate = rate
                {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate) / Double(rate)
                }
                else
                {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate)
                }
            }
            
            // schedule a stop timer for when audio finishes playing
            self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(PlayRecordingsViewController.stopAudio), userInfo: nil, repeats: false)
            RunLoop.main.add(self.stopTimer!, forMode: RunLoop.Mode.default)
        }
        
        do
        {
            try audioEngine.start()
        }
        catch
        {
            showAlert(Alerts.AudioEngineError, message: String(describing: error))
            return
        }
        
        // play the recording
        audioPlayerNode.play()
    }
    
    @objc func stopAudio()
    {
        if let audioPlayerNode = audioPlayerNode
        {
            audioPlayerNode.stop()
        }
        
        if let stopTimer = stopTimer
        {
            stopTimer.invalidate()
        }
        
        configureUI(.notPlaying)
                        
        if let audioEngine = audioEngine
        {
            audioEngine.stop()
            audioEngine.reset()
        }
    }
    
    // MARK: Connect List of Audio Nodes
    
    func connectAudioNodes(_ nodes: AVAudioNode...)
    {
        for x in 0..<nodes.count-1
        {
            audioEngine.connect(nodes[x], to: nodes[x+1], format: audioFile.processingFormat)
        }
    }
    
    // MARK: UI Functions

    func configureUI(_ playState: PlayingState)
    {
        switch(playState)
        {
        case .playing:
            setPlayButtonsEnabled(false)
            stopButton.isEnabled = true
        case .notPlaying:
            setPlayButtonsEnabled(true)
            stopButton.isEnabled = false
        }
    }

    func setPlayButtonsEnabled(_ enabled: Bool)
    {
        playButton.isEnabled = enabled
    }

    func showAlert(_ title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

