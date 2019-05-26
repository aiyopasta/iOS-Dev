//
//  StartHomeworkPopUpViewController.swift
//  LitList
//
//  Created by Aditya Abhyankar on 8/14/16.
//  Copyright © 2016 Aditya Abhyankar. All rights reserved.
//

import UIKit

class StartHomeworkPopUpViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: Properties
    
    @IBOutlet weak var freeTimePickerView: UIPickerView!
    @IBOutlet weak var freeTimeLabel: UILabel!
    @IBOutlet weak var smileyLabel: UILabel!
    @IBOutlet weak var energyLevelChanger: UIStepper!
    
    var smilies: [String] = ["😞", "🙁", "😐", "🙂", "😀"]
    
    var freeTimePickerDataSource = [String]()
    var freeTimeChosen: String!
    var energyLevel = 3
    
    var proceedToHomework = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        freeTimePickerView.delegate = self
        freeTimePickerView.dataSource = self
        
        for i in stride(from: 5, to: 245, by: 5) {
            freeTimePickerDataSource += ["\(i/60) hours \(i%60) mins"]
        }
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        showAnimate()
        
        energyLevelChanger.autorepeat = true
        energyLevelChanger.maximumValue = 4
        
        smileyLabel.text = "🙂"
    }
    
    @IBAction func cancelPopUpMenu(_ sender: UIButton) {
        removeAnimate()
    }
    
    @IBAction func startHomeworkButtonPressed(_ sender: UIButton) {
        proceedToHomework = true
        removeAnimate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: UIPickerView Stuff
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return freeTimePickerDataSource.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return freeTimePickerDataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        freeTimeChosen = freeTimePickerDataSource[pickerView.selectedRow(inComponent: 0)]
        print(freeTimeChosen)
        freeTimeLabel.text = "Free Time: " + freeTimePickerDataSource[pickerView.selectedRow(inComponent: 0)]
    }

    // MARK: PopUp Animations
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.view.removeFromSuperview()
                }
        });
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: Stepper Methods
    
    @IBAction func setEnergy(_ sender: Any) {
        smileyLabel.text = smilies[Int(energyLevelChanger.value)]
        energyLevel = Int(energyLevelChanger.value) + 1
    }
    
    // MARK: Segue Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navVC: UINavigationController = segue.destination as! UINavigationController
        let secondVC: TaskSuggestionViewController = navVC.viewControllers.first as! TaskSuggestionViewController
        
        secondVC.suggestedTask = (self.parent as! TaskTableViewController).student.tasks[0]
        
        // MARK: Google Prediction API / Cloud Thingy Goes Here:
        
        // For now:
        secondVC.predictedTimeInSeconds = 27*5*60
    }
}
