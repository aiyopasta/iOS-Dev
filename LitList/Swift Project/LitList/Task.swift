//
//  Task.swift
//  LitList
//
//  Created by Aditya Abhyankar on 8/3/16.
//  Copyright © 2016 Aditya Abhyankar. All rights reserved.
//

import UIKit

class Task {
    
    // MARK: Properties
    
    var taskTitle: String!
    var course: Course!
    var workSize: Int!
    var daysLeft: Int!
    
    init(title: String, course: Course, workSize: Int, daysLeft: Int) {
        self.taskTitle = title
        self.course = course
        self.workSize = workSize
        self.daysLeft = daysLeft
    }
}
