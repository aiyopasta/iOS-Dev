//
//  TaskTableViewCell.swift
//  LitList
//
//  Created by Aditya Abhyankar on 8/3/16.
//  Copyright © 2016 Aditya Abhyankar. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    // MARK: Properties
    
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var taskIcon: TaskIcon!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
