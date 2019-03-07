//
//  PlayerViewController.swift
//  New UITableView Navigation
//
//  Created by Oleksandr Bardashevskyi on 3/7/19.
//  Copyright © 2019 Oleksandr Bardashevskyi. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    //MARK: - Variables
    
    var player = AVAudioPlayer()
    let widthButton: CGFloat = 100
    var path = String()
    let nameOfSound = UILabel()
    var sliderVolume = UISlider()
    var sliderDuration = UISlider()
    
    let timeLable: UILabel = {
        let tl = UILabel()
        //tl.translatesAutoresizingMaskIntoConstraints = false
        tl.text = "Time: 0:00"
        tl.textAlignment = .center
        return tl
    }()
    let volumeLable: UILabel = {
        let tl = UILabel()
        //tl.translatesAutoresizingMaskIntoConstraints = false
        tl.text = "Volume: 100%"
        tl.textAlignment = .center
        return tl
    }()
    
    let playStopButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Play", for: UIControl.State.normal)
        btn.setTitleColor(UIColor.blue, for: UIControl.State.normal)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.blue.cgColor
        btn.layer.cornerRadius = 20
        btn.backgroundColor = UIColor.lightGray
        btn.addTarget(self, action: #selector(playAction), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    func initWithPath(path: String) -> UIViewController {
        self.path = path
        return self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(stopMusic))
        
        self.view.backgroundColor = #colorLiteral(red: 0.5947291141, green: 0.554311527, blue: 1, alpha: 1)
        
        do {
            let audioPath = URL(fileURLWithPath: self.path)
            try player = AVAudioPlayer(contentsOf: audioPath)
            sliderDuration.maximumValue = Float(player.duration)
        } catch let error as NSError {
            print(error)
        }
        
        addSubViews()
        buttonConstraints()
    }
    //MARK: - Stop
    @objc func stopMusic() {
        self.player.stop()
        playStopButton.setTitle("Play", for: .normal)
        let vc = OBDirectoryTableViewController()
        let filePath = (self.path as NSString).deletingLastPathComponent
        self.navigationController?.pushViewController(vc.initWithFolderPath(path: filePath), animated: true)
    }
    
    //MARK: ButtonFunctions
    @objc func playAction() {
        
        if playStopButton.titleLabel?.text == "Play" {
            playStopButton.setTitle("Pause", for: .normal)
            self.player.play()
            self.animatedSlider(slider: self.sliderDuration)
        } else if playStopButton.titleLabel?.text == "Pause" {
            playStopButton.setTitle("Play", for: .normal)
            self.player.stop()
        }
    }
    //MARK: - Sliders
    @objc func sliderChangedValue(_ sender: UISlider) {
        player.volume = sender.value
        volumeLable.text = "Volume: \(Int(sender.value*100))%"
    }
    @objc func sliderChangedDuration(_ sender: UISlider) {
        
        player.currentTime = TimeInterval(sender.value)
        
    }
    //MARK: - Animation
    
    func animatedSlider(slider: UISlider) {
        
        UISlider.animate(withDuration: player.duration,
                         delay: 0,
                         options: UIView.AnimationOptions.curveLinear,
                         animations: {
                            slider.value = Float(self.player.currentTime)
                            self.timeLable.text = "Time: " + self.formatTime()
        }) { (true) in
            weak var sliderWeak = slider
            self.animatedSlider(slider: sliderWeak!)
        }
    }
    //MARK: - Format time function
    
    func formatTime() -> String{
        let currentTime = Int(player.currentTime)
        let minutes = currentTime/60
        let seconds = currentTime - minutes * 60
        
        return String(format: "%02d:%02d", minutes,seconds) as String
    }
    
    //MARK: - Constraints
    
    func buttonConstraints() {
        
        playStopButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        playStopButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        playStopButton.widthAnchor.constraint(equalToConstant: widthButton).isActive = true
        playStopButton.heightAnchor.constraint(equalToConstant: widthButton).isActive = true
        
        sliderVolume.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY - widthButton)
        volumeLable.center = CGPoint(x: sliderVolume.frame.midX, y: sliderVolume.frame.midY - widthButton/2)
        
        sliderDuration.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY - widthButton*2)
        timeLable.center = CGPoint(x: sliderDuration.frame.midX, y: sliderDuration.frame.midY - widthButton/2)
        self.view.addSubview(playStopButton)
    }
    func addSubViews() {
        
        sliderVolume.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width - 20, height: 20)
        sliderVolume.addTarget(self, action: #selector(sliderChangedValue), for: UIControl.Event.valueChanged)
        volumeLable.frame = CGRect(x: 0, y: 0, width: 150, height: 20)
        
        sliderDuration.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width - 20, height: 20)
        sliderDuration.addTarget(self, action: #selector(sliderChangedDuration), for: UIControl.Event.valueChanged)
        timeLable.frame = CGRect(x: 0, y: 0, width: 200, height: 20)
        
        sliderVolume.value = 1
        sliderVolume.minimumValue = 0
        sliderVolume.maximumValue = 1
        sliderDuration.minimumValue = 0
        
        nameOfSound.text = (path as NSString).lastPathComponent
        nameOfSound.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width - 30, height: 30)
        nameOfSound.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.maxY - 30)
        
        self.view.addSubview(nameOfSound)
        self.view.addSubview(sliderVolume)
        self.view.addSubview(sliderDuration)
        self.view.addSubview(playStopButton)
        self.view.addSubview(volumeLable)
        self.view.addSubview(timeLable)
    }


}
