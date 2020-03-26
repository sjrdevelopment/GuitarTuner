//
//  ViewController.swift
//  GuitarTuner
//
//  Created by Stuart Robinson on 31/12/2019.
//  Copyright © 2019 Stuart Robinson. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI

class ViewController: UIViewController {
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    
    let noteFrequencies = [18.35, 20.6, 24.5, 27.5, 30.87]
    let noteNames = ["D", "E", "G", "A", "B"]
    
    @IBOutlet weak var amplitudeLabel: UILabel!
    
    @IBOutlet weak var actualLabel: UILabel!
    
    @IBOutlet weak var targetLabel: UILabel!
    
    @IBOutlet weak var noteNameLabel: UILabel!
    
    @IBOutlet weak var triLeft: UIImageView!
    
    @IBOutlet weak var triRight: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker(mic)
        silence = AKBooster(tracker, gain: 0)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        AudioKit.output = silence
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        setupPlot()
        Timer.scheduledTimer(timeInterval: 0.1,
                             target: self,
                             selector: #selector(ViewController.updateUI),
                             userInfo: nil,
                             repeats: true)
    }
    
    
    @IBAction func onButtonClick(_ sender: UIButton) {
       

    }
    
    @IBOutlet weak var audioInputPlot: EZAudioPlot!
    
    func setupPlot() {
        let plot = AKNodeOutputPlot(mic, frame: audioInputPlot.bounds)
        plot.plotType = .rolling
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.color = UIColor.green
        audioInputPlot.addSubview(plot)
    }
    
    @objc func updateUI() {
        if tracker.amplitude > 0.1 {
         
            var frequency = Float(tracker.frequency)
            while (frequency > Float(noteFrequencies[noteFrequencies.count-1])) {
                frequency = frequency / 2.0
            }
            while (frequency < Float(noteFrequencies[0])) {
                frequency = frequency * 2.0
            }
            
            var minDistance: Float = 10000.0
            var index = 0
            
            for i in 0..<noteFrequencies.count {
                let distance = fabsf(Float(noteFrequencies[i]) - frequency)
                if (distance < minDistance){
                    index = i
                    minDistance = distance
                }
            }
            let octave = Int(log2f(Float(tracker.frequency) / frequency))
            noteNameLabel.text = "\(noteNames[index])\(octave)"
           
            actualLabel.text = "\(frequency)"
            targetLabel.text = "\(noteFrequencies[index])"
            
            let threshold = 0.5
            
            if (Float(frequency) <= Float(noteFrequencies[index]-threshold)) {
                triLeft.isHidden = false
                triRight.isHidden = true
            } else if (Float(frequency) >= Float(noteFrequencies[index]+threshold)) {
                triLeft.isHidden = true
                triRight.isHidden = false
            } else {
                triLeft.isHidden = true
                triRight.isHidden = true
            }
            
        }
        amplitudeLabel.text = String(format: "%0.2f", tracker.amplitude)
    }
    

}

