//
//  recorderViewController.swift
//  classmate
//
//  Created by Sushanth on 12/01/16.
//  Copyright © 2016 Sushanth. All rights reserved.
//




import UIKit
import AVFoundation
import Foundation






class RecordedAudio : NSObject{
    
    var filepathURL :NSURL!
    var title : String!
}

extension String {
    func stringByAppendingPathComponent(pathComponent: String) -> String {
        return (self as NSString).appendingPathComponent(pathComponent)
    }
}
extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-DD-yyyy HH:mm:ss"
        return dateFormatter.string(from: self)
    }
}

class recorderViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    @IBOutlet var RecordBTN: UIButton!
    @IBOutlet var PlayBTN: UIButton!
    @IBOutlet weak var textLabel: UILabel!

    var temp = "temp"
    let recordingName = Date().toString()
    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    var recordedAudio: RecordedAudio!
    var isAlreadyRecorded: Bool = false
    var audioFilePath: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(isAlreadyRecorded){
            PlayBTN.isEnabled = true
            RecordBTN.isHidden = true
            textLabel.text = audioFilePath.lastPathComponent
        }else{
            RecordBTN.isHidden = false
            PlayBTN.isHidden = true
            textLabel.text = temp
        }
        //PlayBTN.isEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupRecorder(){
        let audioFilename = getDocumentsDirectory().appendingPathComponent( temp + recordingName + "recording.m4a")
        //print(audioFilename)
        let recordSettings = [ AVFormatIDKey: kAudioFormatAppleLossless,
                               AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
                               AVEncoderBitRateKey: 320000,
                               AVNumberOfChannelsKey: 2,
                               AVSampleRateKey: 44100.0 ] as [String : Any]
       
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.setActive(true)
            soundRecorder =  try AVAudioRecorder(url: audioFilename, settings: recordSettings)
            soundRecorder.delegate = self

        } catch _ {
            print("Error")
        }
        soundRecorder.delegate = self
        soundRecorder.prepareToRecord()
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    @IBAction func record(_ sender: UIButton) {
        if sender.titleLabel?.text == "Record"{
            setupRecorder()
            soundRecorder.record()
            sender.setTitle("Stop", for: .normal)
            PlayBTN.isHidden = false
            PlayBTN.isEnabled = false
            
        }
        else{
            soundRecorder.stop()
            sender.setTitle("Record", for: .normal)
            RecordBTN.isHidden = true
            PlayBTN.isHidden = false
            PlayBTN.isEnabled = false
            
        }
    }
    
    @IBAction func play(_ sender: UIButton) {
        if sender.titleLabel?.text == "Play" {
            preparePlayer()
            if soundPlayer != nil {
                RecordBTN.isEnabled = false
                sender.setTitle("Stop", for: .normal)
                soundPlayer.play()
            }
        }
        else if soundPlayer != nil {
            soundPlayer.stop()
            sender.setTitle("Play", for: .normal)
            
        }
}
    
    func preparePlayer() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
            if(!self.isAlreadyRecorded){
                audioFilePath = getDocumentsDirectory().appendingPathComponent(temp + recordingName + "recording.m4a")
            }
            print(audioFilePath)
            soundPlayer = try AVAudioPlayer(contentsOf: audioFilePath)
        } catch _ {
            print("Error")
        }
        if soundPlayer != nil {
        soundPlayer.delegate = self
        soundPlayer.prepareToPlay()
        soundPlayer.volume = 1.0
            soundPlayer.play()
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        PlayBTN.isEnabled = true
        recordedAudio = RecordedAudio()
        recordedAudio.filepathURL = recorder.url as NSURL!
        recordedAudio.title = recorder.url.lastPathComponent
        //print(recordedAudio.title)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        RecordBTN.isEnabled = true
        PlayBTN.setTitle("Play", for: .normal)
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil);
    }
}
