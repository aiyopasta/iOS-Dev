//
//  TaskTableViewController.swift
//  LitList
//
//  Created by Aditya Abhyankar on 8/3/16.
//  Copyright © 2016 Aditya Abhyankar. All rights reserved.
//

// MARK: Problems / Bugs to fix:

// 1. Task Icon problem where after a task is deleted and another is added to same column the new icon overlaps with the previous information for some reason.

// 2. Change status bar color when start homework button is pressed.

// 3. Start actually Persisting Data using the NSCoding thing so that tasks reload everytime view controller is presented.

// 4. For some reason, the task finished screen pops up again after clicking table screen.

import UIKit

class TaskTableViewController: UITableViewController {

    // MARK: Properties
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var startHomeworkButton: UIBarButtonItem!
    
    var student = Student(name: "Aditya", constants_0: ["energyFactor": 0.3, "timeFactor": 0.3, "dueDateFactor": 0.4, "assignmentEarlinessFactor": 0.7, "energyMinimizationFactor": 0.4, "energyMaximizationFactor": 0.7, "timeMinimizationFactor": 0.4, "timeMaximizationFactor": 0.7], courses: [Course(title: "AP Physics C", teacherName: "Cakir", teacherToughness: 3), Course(title: "AP Statistics", teacherName: "Dentler", teacherToughness: 1), Course(title: "English IV", teacherName: "Snyder", teacherToughness: 1)])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
        
        startHomeworkButton.isEnabled = false
        
        // Load sample data.
        loadSampleTasks()
    }
    
    func loadSampleTasks() {
        let sampleTask = Task(title: "BBR Chapter 5", course: student.courses[0], workSize: 6, daysLeft: 20)
        let sampleTask2 = Task(title: "Chapter 15 Problems", course: student.courses[1], workSize: 1, daysLeft: 2)
        let sampleTask3 = Task(title: "TED-Talk Outline", course: student.courses[2], workSize: 0, daysLeft: 40)
        student.tasks += [sampleTask, sampleTask2, sampleTask3]
        
        startHomeworkButton.isEnabled = true
    }
    
    // Start Homework Popup View
    
    @IBAction func queueStartHomeworkViewPopup(_ sender: UIBarButtonItem) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "startHomeworkPopUpVC") as! StartHomeworkPopUpViewController
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return student.tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "TaskTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TaskTableViewCell
        
        let task = student.tasks[(indexPath as NSIndexPath).row]
        cell.courseNameLabel.text = task.course.title
        cell.taskTitleLabel.text = task.taskTitle
        print(String(task.course.title[task.course.title.startIndex]))
        cell.taskIcon.iconLetters = String(task.course.title[task.course.title.startIndex])
        cell.taskIcon.timeLeft = String(task.daysLeft!) + " Days Left"
        cell.taskIcon.taskDifficulty = task.workSize
        
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            student.tasks.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if (student.tasks.isEmpty) {
                startHomeworkButton.isEnabled = false
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Segue Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navVC: UINavigationController = segue.destination as! UINavigationController
        let secondVC: AddNewTaskViewController = navVC.viewControllers.first as! AddNewTaskViewController
        
        var dataSources = [String]()
        
        for course in student.courses {
            dataSources += [course.title]
        }
        
        secondVC.coursePickerDataSource = dataSources
        secondVC.student = self.student
    }
    
    @IBAction func unwindToTaskTable(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? AddNewTaskViewController, let task = sourceViewController.newTask {
            let newIndexPath = NSIndexPath(row: student.tasks.count, section: 0)
            student.tasks.append(task)
            tableView.insertRows(at: [newIndexPath as IndexPath], with: .bottom)
            startHomeworkButton.isEnabled = true
        }
    }
}
