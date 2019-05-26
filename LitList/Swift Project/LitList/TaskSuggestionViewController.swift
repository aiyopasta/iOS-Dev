//
//  TaskSuggestionViewController.swift
//  LitList
//
//  Created by Aditya Abhyankar on 8/14/16.
//  Copyright © 2016 Aditya Abhyankar. All rights reserved.
//

import UIKit

class TaskSuggestionViewController: UIViewController {

    @IBOutlet weak var suggestedTaskIcon: TaskIcon!
    @IBOutlet weak var suggestedTaskTitle: UILabel!
    @IBOutlet weak var suggestedCourseName: UILabel!
    @IBOutlet weak var digitalTimeLabel: UILabel!
    @IBOutlet weak var englishTimeLabel: UILabel!
    @IBOutlet weak var topToolBar: UINavigationItem!
    
    var suggestedTask: Task!
    var predictedTimeInSeconds: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        suggestedCourseName.text = suggestedTask.course.title
        topToolBar.title = suggestedTask.course.title
        suggestedTaskTitle.text = suggestedTask.taskTitle
        suggestedTaskIcon.iconLetters = String(suggestedTask.course.title[suggestedTask.course.title.startIndex])
        suggestedTaskIcon.timeLeft = String(suggestedTask.daysLeft!) + " Days Left"
        suggestedTaskIcon.taskDifficulty = suggestedTask.workSize
        
        let currentTime = Date()
        let endTime = currentTime.addingTimeInterval(Double(predictedTimeInSeconds))
        let calendar = Calendar.current
        let comp = calendar.dateComponents([.hour, .minute], from: endTime)
        
        digitalTimeLabel.text = "\(comp.hour!%12):\(comp.minute!)"
        englishTimeLabel.text = "\(predictedTimeInSeconds/3600) Hour(s) and \(predictedTimeInSeconds/60%60) Minute(s)"
        
        if (String(comp.minute!).characters.count==1) {
            digitalTimeLabel.text = "\(comp.hour!%12):0\(comp.minute!)"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextVC: HomeworkInProgressViewController = segue.destination as! HomeworkInProgressViewController
        
        nextVC.suggestedTask = suggestedTask
        nextVC.predictedTimeInSeconds = predictedTimeInSeconds
        
        if (predictedTimeInSeconds/60/25>0 && predictedTimeInSeconds/60 != 25) {
            nextVC.timeTillBreak = 25*60
        }
        else {
            nextVC.timeTillBreak = predictedTimeInSeconds + 1
            nextVC.noMoreBreaksInitial = true
        }
    }

}
