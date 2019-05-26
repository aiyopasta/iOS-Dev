//
//  Course.swift
//  LitList
//
//  Created by Aditya Abhyankar on 8/6/16.
//  Copyright © 2016 Aditya Abhyankar. All rights reserved.
//

import UIKit

class Course {
    
    // MARK: Properties
    
    var title: String
    var courseLevel: Int!
    var teacherName: String!
    var teacherToughness: Int!
    
    // MARK: Initialization
    
    init(title: String, teacherName: String, teacherToughness: Int) {
        self.title = title
        self.teacherName = teacherName
        self.teacherToughness = teacherToughness
        
        switch title.uppercased() {
        case let x where x.hasPrefix("AP"):
            courseLevel = 4
        case let x where x.hasPrefix("HONORS"):
            courseLevel = 3
        case let x where x.hasPrefix("ADVANCED"):
            courseLevel = 2
        default:
            courseLevel = 1
        }
    }
}
