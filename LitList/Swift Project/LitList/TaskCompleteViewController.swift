//
//  TaskCompleteViewController.swift
//  LitList
//
//  Created by Aditya Abhyankar on 10/8/16.
//  Copyright © 2016 Aditya Abhyankar. All rights reserved.
//

import UIKit

class TaskCompleteViewController: UIViewController {

    var suggestedTask: Task!
    var finished: Bool!
    var timeTaken: Int!
    var breaks: Int!
    
    var interestLevel: Int!
    var actualEnergyNeeded: Int!
    
    @IBOutlet weak var taskIcon: TaskIcon!
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var courseTitle: UILabel!
    @IBOutlet weak var timeTakenLabel: UILabel!
    @IBOutlet weak var breaksTakenLabel: UILabel!
    @IBOutlet weak var taskCompletedSwitch: UISwitch!
    @IBOutlet weak var prodSelector: UISegmentedControl!
    @IBOutlet weak var interestSelector: UISegmentedControl!
    
    @IBOutlet weak var q1Label: UILabel!
    @IBOutlet weak var q2Label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        taskIcon.iconLetters = String(suggestedTask.course.title[suggestedTask.course.title.startIndex])
        taskIcon.timeLeft = String(suggestedTask.daysLeft!) + " Days Left"
        taskIcon.taskDifficulty = suggestedTask.workSize
        taskTitle.text = suggestedTask.taskTitle
        courseTitle.text = suggestedTask.course.title
        
        timeTakenLabel.text = "\(timeTaken/3600)h \(timeTaken/60%60)m \(timeTaken%3600%60)s"
        breaksTakenLabel.text = String(breaks)
        taskCompletedSwitch.isEnabled = false
        taskCompletedSwitch.setOn(finished, animated: true)
        
        if (!finished!) {
            q1Label.isHidden = true
            q2Label.isHidden = true
            prodSelector.isHidden = true
            interestSelector.isHidden = true
        }
    }
    
    @IBAction func interestSelected(_ sender: Any) {
        switch interestSelector.selectedSegmentIndex {
            case 0:
                interestSelector.tintColor = UIColor.red
            case 1:
                interestSelector.tintColor = UIColor.orange
            case 2:
                interestSelector.tintColor = UIColor.yellow
            case 3:
                interestSelector.tintColor = UIColor.green
            default:
                break;
        }
        
        interestLevel = interestSelector.selectedSegmentIndex
    }

    @IBAction func productivitySelected(_ sender: Any) { // To measure energy level after assignment.
        switch prodSelector.selectedSegmentIndex {
            case 0:
                prodSelector.tintColor = UIColor.red
            case 1:
                prodSelector.tintColor = UIColor.purple
            case 2:
                prodSelector.tintColor = UIColor.orange
            case 3:
                prodSelector.tintColor = UIColor.yellow
            case 4:
                prodSelector.tintColor = UIColor.green
            default:
                break;
        }
        
        actualEnergyNeeded = prodSelector.selectedSegmentIndex
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Save the new data into the cloud here...
        
        let navVC: UINavigationController = segue.destination as! UINavigationController
        let secondVC: TaskTableViewController = navVC.viewControllers.first as! TaskTableViewController
        
        print(finished)
        
        if (finished!) {
            print("in if")
            let totalTasks = secondVC.student.tasks.count
            for index in 0..<totalTasks {
                if (secondVC.student.tasks[secondVC.student.tasks.index(after: index)].taskTitle==suggestedTask.taskTitle) {
                    secondVC.student.tasks.remove(at: secondVC.student.tasks.index(after: index))
                }
            }
        }
    }
}
