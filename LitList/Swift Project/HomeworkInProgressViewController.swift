//
//  HomeworkInProgressViewController.swift
//  LitList
//
//  Created by Aditya Abhyankar on 8/15/16.
//  Copyright © 2016 Aditya Abhyankar. All rights reserved.
//

import UIKit
import AVFoundation

class HomeworkInProgressViewController: UIViewController {
    
    var noMoreBreaksInitial = false
    
    var suggestedTask: Task!
    var predictedTimeInSeconds: Int!
    var timeLeftInSeconds: Int!
    var timeTillBreak: Int!
    var breakTimeInSeconds: Int! = 5*60
    
    var isBreak: Bool! = false {
        didSet {
            playDing()
        }
    }
    
    var timer: Timer!
    
    var audioPlayer = AVAudioPlayer()
    
    var taskComplete: Bool! = false
    var breaksTaken: Int! = 0
    
    var extraTimeRunning: Bool! = false
    
    @IBOutlet weak var taskIcon: TaskIcon!
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var courseTitle: UILabel!
    @IBOutlet weak var elapsedTimeLeftClock: UILabel!
    @IBOutlet weak var clockSubtitle: UILabel!
    @IBOutlet weak var breakProgressBar: UIProgressView!
    @IBOutlet weak var breakTextView: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskTitle.text = suggestedTask.taskTitle
        courseTitle.text = suggestedTask.course.title
        elapsedTimeLeftClock.text = "\(predictedTimeInSeconds/3600)h \(predictedTimeInSeconds/60%60)m \(predictedTimeInSeconds%3600%60)s"
        
        if (!noMoreBreaksInitial) {
            breakTextView.text = "Break In: \(timeTillBreak!/60%60)m \(timeTillBreak!%3600%60)s"
        }
        else {
            breakTextView.text = "No More Breaks"
            breakProgressBar.setProgress(1, animated: true)
        }
        
        taskIcon.iconLetters = String(suggestedTask.course.title[suggestedTask.course.title.startIndex])
        taskIcon.timeLeft = String(suggestedTask.daysLeft!) + " Days Left"
        taskIcon.taskDifficulty = suggestedTask.workSize
        
        timeLeftInSeconds = predictedTimeInSeconds;
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(HomeworkInProgressViewController.update), userInfo: nil, repeats: true)
    }
    
    @IBAction func endTask(_ sender: AnyObject) {
        let optionMenuController = UIAlertController(title: "Done", message: "LitList recommends you continue until you are either finished or the time runs out, but you can quit without finishing if you absolutely must.", preferredStyle: .actionSheet)
        
        let finishedEarly = UIAlertAction(title: "Finish Early", style: UIAlertActionStyle.default, handler: {
            UIAlertAction in
            print("Finished Early")
            self.taskComplete = true
            self.performSegue(withIdentifier: "taskFinished", sender: nil)
            self.timer.invalidate()
        })
        
        let quit = UIAlertAction(title: "Quit Without Finishing", style: UIAlertActionStyle.destructive, handler: {
            UIAlertAction in
            print("Quit")
            self.taskComplete = false
            self.performSegue(withIdentifier: "taskFinished", sender: nil)
            self.timer.invalidate()
        })
        
        let cancel = UIAlertAction(title: "Continue Working", style: UIAlertActionStyle.cancel, handler: {
            UIAlertAction in
            print("Cancel")
        })
        
        optionMenuController.addAction(finishedEarly)
        optionMenuController.addAction(quit)
        optionMenuController.addAction(cancel)
        
        self.present(optionMenuController, animated: true, completion: nil)
    }
    
    func update() {
        
        /*print("timeLeftInSeconds: \(timeLeftInSeconds)")
        print("timeTillBreak: \(timeTillBreak)")
        print("breaksTaken: \(breaksTaken)")
        print("isBreak: \(isBreak)")
        print("breakTimeInSeconds: \(breakTimeInSeconds)")*/
        
        if (timeTillBreak>0) {
            
            if (isBreak!) {
                isBreak! = false
            }
            
            timeTillBreak! -= 1
            timeLeftInSeconds! -= 1
            
            if (!(breakTextView.text?.hasPrefix("No More Breaks"))!) {
                breakTextView.text = "Break in: \(timeTillBreak!/60%60)m \(timeTillBreak!%3600%60)s"
                breakProgressBar.setProgress(1 - Float(timeTillBreak!)/(25*60), animated: true)
            }
            
            if (timeLeftInSeconds<=0) {
                
                timer.invalidate()
                self.playDing()
                
                if (!extraTimeRunning) {
                
                    let finishedOrNotActionSheet = UIAlertController(title: "Time Finished", message: "Have you completed the assignment?", preferredStyle: .alert)
                
                    var taskComplete = UIAlertAction(title: "Task Complete", style: UIAlertActionStyle.default, handler: {
                        UIAlertAction in
                        print("session ended")
                        self.taskComplete = true
                        self.performSegue(withIdentifier: "taskFinished", sender: nil)
                    })
                
                    let taskNotComplete = UIAlertAction(title: "Task Incomplete", style: UIAlertActionStyle.default, handler: {
                        UIAlertAction in
                        print("session ended")
                        self.taskComplete = false
                        self.performSegue(withIdentifier: "taskFinished", sender: nil)
                    })
                
                    let extraTime = UIAlertAction(title: "Provide 5 More Minutes to Finish", style: UIAlertActionStyle.cancel, handler: {
                        UIAlertAction in
                    
                        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(HomeworkInProgressViewController.update), userInfo: nil, repeats: true)
                        self.timeLeftInSeconds = 5*60
                        self.timeTillBreak = self.timeLeftInSeconds + 1
                        self.extraTimeRunning = true
                    
                    })

                    finishedOrNotActionSheet.addAction(taskComplete)
                    finishedOrNotActionSheet.addAction(taskNotComplete)
                    finishedOrNotActionSheet.addAction(extraTime)
                
                    self.present(finishedOrNotActionSheet, animated: true, completion: nil)
                    
                }
                else {
                    playDing()
                    print("session ended")
                    taskComplete = true
                    performSegue(withIdentifier: "taskFinished", sender: nil)
                }
            }
            
            elapsedTimeLeftClock.text = "\(timeLeftInSeconds!/3600)h \(timeLeftInSeconds!/60%60)m \(timeLeftInSeconds!%3600%60)s"
            clockSubtitle.text = "Left For This Task"

        }
        else {
            
            if (!isBreak!) {
                isBreak! = true
            }
            
            breakTextView.text = "Break ends in: \(breakTimeInSeconds/60%60)m \(breakTimeInSeconds%3600%60)s"
            
            if ((breaksTaken+1)%4==0) {
                breakProgressBar.setProgress(1 - Float(breakTimeInSeconds!)/(15*60), animated: true)
            }
            else {
                breakProgressBar.setProgress(1 - Float(breakTimeInSeconds!)/(5*60), animated: true)
            }
            
            clockSubtitle.text = "\(timeLeftInSeconds!/3600)h \(timeLeftInSeconds!/60%60)m Left For This Task"
            
            if ((breaksTaken+1)%4==0) {
                elapsedTimeLeftClock.text = "15m Break"
            }
            else {
                elapsedTimeLeftClock.text = "5m Break"
            }
            
            breakTimeInSeconds! -= 1
            
            if (breakTimeInSeconds<=0) {
                
                breaksTaken! += 1
                
                if (timeLeftInSeconds/60/25>0) {
                    breakTextView.text = "Break in: \(timeLeftInSeconds!/60%60)m \(timeLeftInSeconds!%3600%60)s"
                    timeTillBreak = 25*60
                    
                    if ((breaksTaken+1)%4==0) {
                        breakTimeInSeconds! = (15*60)
                    }
                    else {
                        breakTimeInSeconds! = (5*60)
                    }
                }
                else {
                    breakTextView.text = "No More Breaks"
                    timeTillBreak = timeLeftInSeconds + 1
                }
            }
        }
        
    }
    
    func playDing() {
        do {
            if let bundle = Bundle.main.path(forResource: "Ding", ofType: "wav") {
                let alertSound = NSURL(fileURLWithPath: bundle)
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(true)
                try audioPlayer = AVAudioPlayer(contentsOf: alertSound as URL)
                audioPlayer.prepareToPlay()
                audioPlayer.play()
                
                //while(audioPlayer.isPlaying){}
            }
        } catch {
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navVC: UINavigationController = segue.destination as! UINavigationController
        let secondVC: TaskCompleteViewController = navVC.viewControllers.first as! TaskCompleteViewController
        
        secondVC.suggestedTask = suggestedTask
        secondVC.finished = taskComplete
        print(taskComplete)
        secondVC.timeTaken = predictedTimeInSeconds - timeLeftInSeconds
        
        if (extraTimeRunning!) {
            secondVC.timeTaken! += 5*60
        }
        
        secondVC.breaks = breaksTaken
        
    }
    
    // The following two methods are for testing only. Add two buttons and link them to the methods to test.
    
    @IBAction func rewindTime(_ sender: AnyObject) {
        if ((breakTextView.text?.hasPrefix("Break ends in: "))!) {
            breakTimeInSeconds! += 30
        }
        else {
            timeLeftInSeconds! += 60
            timeTillBreak! += 60
        }
    }
    
    @IBAction func forwardTime(_ sender: AnyObject) {
        if ((breakTextView.text?.hasPrefix("Break ends in: "))!) {
            breakTimeInSeconds! -= 30
        }
        else {
            timeLeftInSeconds! -= 30
            timeTillBreak! -= 30
        }
    }
}
