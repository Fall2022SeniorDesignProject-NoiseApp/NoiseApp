//
//  PlayRecordingsViewController.swift
//  NoiseApp
//
//  Created by Mitchel Santillan Cruz on 9/1/22.
//

import Foundation
import UIKit
import AVFoundation

class PlayRecordingsViewController: UIViewController
{
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    var recordedAudioURL: URL!
    var audioFile: AVAudioFile!
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupAudio()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        configureUI(.notPlaying)
    }
    
    @IBAction func pressedPlay(_ sender: UIButton)
    {
        playSound(rate: 1.0)
        configureUI(.playing)
    }
    
    @IBAction func pressedStop(_ sender: UIButton)
    {
        stopAudio()
    }
    
    @IBAction func pressedHome(_ sender: UIButton)
    {
        dismiss(animated: true)
    }
    
    
}

