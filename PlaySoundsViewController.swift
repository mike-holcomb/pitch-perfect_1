//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Mike Holcomb on 6/4/15.
//  Copyright (c) 2015 Mike Holcomb. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    // Declare global variables
    var audioPlayer: AVAudioPlayer!
    var receivedAudio: RecordedAudio!
    
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    
    //Enum for switching effects selector for extra credit effects
    enum Effects {
        case Echo
        case Reverb
    }
    
    // Load recorded file into audioPlayer and audioEngine after loading view
    override func viewDidLoad() {
        super.viewDidLoad()

        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathURL, error: nil)
        audioPlayer.enableRate = true
        
        audioEngine = AVAudioEngine()
        audioFile = AVAudioFile(forReading: receivedAudio.filePathURL, error: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
/**************************************************

    BUTTON ACTION RECEIVERS

************************************************/
    
    @IBAction func playSoundSlowly(sender: UIButton) {
        playAudioWithRate(0.5)
    }
    @IBAction func playSoundFast(sender: UIButton) {
        playAudioWithRate(1.5)
    }
    
    @IBAction func playSoundChipmunk(sender: UIButton) {
        playAudioWithVariablePitch(1000)
    }
    
    @IBAction func playSoundDarthVader(sender: UIButton) {
        playAudioWithVariablePitch(-1000)
    }
    
    @IBAction func playSoundEcho(sender: UIButton) {
        playAudioWithEffect(Effects.Echo,wetDryMix: 50)
    }
    
    @IBAction func playSoundReverb(sender: UIButton) {
        playAudioWithEffect(Effects.Reverb,wetDryMix: 50)
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        stopAudioPlayback()
    }
    
/*******************************************

    EFFECT FUNCTIONS
    
********************************************/
    
    //Variable speed playback; consider refactoring to AVAudioEngine approach
    func playAudioWithRate(newRate: Float){
        stopAudioPlayback()
        audioPlayer.rate = newRate
        audioPlayer.currentTime = 0.0
        audioPlayer.play()
    }
    
    //Variable pitch playback functions for vader and chipmunk; consider refactoring into effect selector
    func playAudioWithVariablePitch(pitch: Float){
        stopAudioPlayback()
        
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        var changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngine.attachNode(changePitchEffect)
        
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        
        audioEngine.startAndReturnError(nil)
        
        audioPlayerNode.play()
    }
    
    
    //Switching function for echo and reverb effect mixers
    func playAudioWithEffect(effect: Effects, wetDryMix: Float){
        stopAudioPlayback()
        
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        
        // Choose the effect
        var audioEffectNode: AVAudioUnitEffect!
        
        switch effect{
            case Effects.Echo:
                var t = AVAudioUnitDelay() as AVAudioUnitDelay
                t.wetDryMix = wetDryMix
                audioEffectNode = t
            case Effects.Reverb:
                var t = AVAudioUnitReverb() as AVAudioUnitReverb
                t.wetDryMix = wetDryMix
                t.loadFactoryPreset(AVAudioUnitReverbPreset.LargeChamber)
                audioEffectNode = t
            default:
                audioEffectNode = AVAudioUnitEffect()
        }
        
        audioEngine.attachNode(audioEffectNode)
        //END - Effect selection
        
        //Connect nodes together
        audioEngine.connect(audioPlayerNode, to: audioEffectNode, format: nil)
        audioEngine.connect(audioEffectNode, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        
        audioPlayerNode.play()
    }
    
    //To fix Task 3 bug, refactor stop/reset routines into one function called at the head of each playback function
    func stopAudioPlayback(){
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
    }
}