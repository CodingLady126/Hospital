//
//  PatientCell.swift
//  Hospital
//
//  Created by Alex on 7/30/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import UIKit



class PatientCell: UITableViewCell {
    
    @IBOutlet weak var noLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

 
    }

}
