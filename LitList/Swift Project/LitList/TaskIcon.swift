//
//  TaskIcon.swift
//  LitList
//
//  Created by Aditya Abhyankar on 8/3/16.
//  Copyright © 2016 Aditya Abhyankar. All rights reserved.
//

import UIKit

class TaskIcon: UIView {
    
    // MARK: Properties
    
    var iconLetters: String?
    var timeLeft: String?
    var taskDifficulty: Int? {
        didSet {
            setNeedsLayout()
        }
    }
    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        let colorWeight = CGFloat(taskDifficulty!)/6*255
        self.backgroundColor = UIColor(red: colorWeight, green: 255-colorWeight, blue: 0, alpha: 0.65)
        
        let letterLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 3*self.frame.size.height/4))
        letterLabel.center = CGPoint(x: self.frame.size.width/2, y: letterLabel.frame.size.height/1.6)
        letterLabel.font = UIFont(name: "Avenir", size: letterLabel.frame.size.height)
        letterLabel.textAlignment = NSTextAlignment.center
        letterLabel.text = iconLetters
        addSubview(letterLabel)
        
        let daysLeftLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height/4))
        daysLeftLabel.center = CGPoint(x: self.frame.size.width/2, y: letterLabel.frame.size.height + daysLeftLabel.frame.size.height/2)
        daysLeftLabel.font = UIFont(name: "Avenir", size: daysLeftLabel.frame.size.height/1.6)
        daysLeftLabel.textAlignment = NSTextAlignment.center
        daysLeftLabel.text = timeLeft
        addSubview(daysLeftLabel)
    }

}
