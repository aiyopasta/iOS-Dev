//
//  AddNewTaskViewController.swift
//  LitList
//
//  Created by Aditya Abhyankar on 8/4/16.
//  Copyright © 2016 Aditya Abhyankar. All rights reserved.
//

import UIKit

class AddNewTaskViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: Properties
    
    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var dueDateLabel: UILabel!
    var date: Date!
    
    @IBOutlet weak var coursePicker: UIPickerView!
    @IBOutlet weak var courseChosenLabel: UILabel!
    var courseChosen: String!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var student: Student!
    
    var coursePickerDataSource = [String]()
    
    var newTask: Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        taskTitleTextField.delegate = self
        coursePicker.delegate = self
        coursePicker.dataSource = self
        
        addButton.isEnabled = false
        
        courseChosen = student.courses[0].title
        date = NSDate() as Date!
    }
    
    // MARK: Actions
    
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func datePickerAction(_ sender: UIDatePicker) {
        date = dueDatePicker.date
    }
    
    // MARK: UITextField delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        addButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        addButton.isEnabled = !(taskTitleTextField.text?.isEmpty)!
    }
    
    // MARK: UIPickerView Stuff
    
   func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return coursePickerDataSource.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return coursePickerDataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        courseChosen = coursePickerDataSource[pickerView.selectedRow(inComponent: 0)]
    }
    
    // MARK: Segue Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if addButton === sender as! UIBarButtonItem {
            
            var course: Course!
            
            for course_0 in student.courses {
                if course_0.title == courseChosen {
                    course = course_0
                }
            }
            
            let calendar: Calendar = Calendar.current
            
            let date1 = calendar.startOfDay(for: NSDate() as Date)
            let date2 = calendar.startOfDay(for: date)
            
            let components = calendar.dateComponents([.day], from: date1, to: date2)
            
            newTask = Task(title: taskTitleTextField.text!, course: course, workSize: Int(arc4random_uniform(6) + 1), daysLeft: components.day!)
        }
    }
}
