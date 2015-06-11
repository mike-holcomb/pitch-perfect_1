//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Mike Holcomb on 6/1/15.
//  Copyright (c) 2015 Mike Holcomb. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    // Declare global variables
    // Global outlets
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    //Global audio variables
    var audioRecorder:AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    var pauseState: Bool!
    var pauseImage: UIImage!
    var resumeImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pauseImage = UIImage(named: "pause")
        resumeImage = UIImage(named: "resume")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Initialize view state for show/hide/enable settings
    override func viewWillAppear(animated: Bool) {
        stopButton.hidden = true
        
        recordButton.enabled = true
        recordLabel.text = "Tap to record"
        
        pauseButton.hidden = true
        pauseButton.setImage(pauseImage, forState: UIControlState.Normal)
        pauseState = true
    }

    @IBAction func recordAudio(sender: AnyObject) {
        recordButton.enabled = false
        stopButton.hidden = false
        pauseButton.hidden = false
        recordLabel.text = "Recording..."
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        
        let recordingName = "my_audio.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        println(filePath)
        
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if(flag){
            //Step 1 - Save the recorded audio
            recordedAudio = RecordedAudio(fileURL: recorder.url, fileTitle: recorder.url.lastPathComponent!)
            
            //Step 2 - Move to the next scene
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        } else {
            recordButton.enabled = true
            stopButton.hidden = true
            
            //cribbed from http://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift
            var alert = UIAlertController(title: "This is embarrasing!", message: "Audio did not record", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecording"){
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            let data = sender as! RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
    
    @IBAction func pauseAudio(sender: AnyObject) {
        if pauseState! {
            pauseButton.setImage(resumeImage, forState: UIControlState.Normal)
            recordLabel.text = "Recording paused, press play to resume"
            pauseState = false
            audioRecorder.pause()
        } else {
            pauseButton.setImage(pauseImage, forState: UIControlState.Normal)
            recordLabel.text = "Recording resumed"
            audioRecorder.record()
            pauseState = true
        }
    }
    
    @IBAction func stopAudio(sender: AnyObject) {
        //consider refactoring label visibility/status text into view state manager
        println("Stopped recording")
        
        audioRecorder.stop()
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
    }
}