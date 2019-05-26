//
//  Student.swift
//  LitList
//
//  Created by Aditya Abhyankar on 8/4/16.
//  Copyright © 2016 Aditya Abhyankar. All rights reserved.
//

import UIKit

class Student {
    // MARK: Properties
    
    var name: String!
    var courses = [Course]()
    var tasks = [Task]()
    var constants: [String: Float]
    
    // MARK: Initialization
    
    init(name: String, constants_0: [String: Float], courses: [Course]) {
        self.name = name
        self.constants = constants_0
        self.courses = courses
    }
    
    func printConstants() {
        print(constants)
    }
}
