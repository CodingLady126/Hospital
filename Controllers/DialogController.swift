//
//  DialogController.swift
//  Hospital
//
//  Created by Alex on 7/30/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import UIKit


protocol SaveTappedDelegate {
    func saveTapped(_ sender: Any)
}


class DialogController: UIViewController {
    
    @IBOutlet weak var segment: UISegmentedControl!
    var type_tag = ["type": "exist", "save": "with"]
    var flag = ""
    
    var delegate: SaveTappedDelegate!
    
    @IBOutlet weak var topConst: NSLayoutConstraint!
    @IBOutlet weak var bottomConst: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupXibContainerViewFrame()
        
        if flag == "edit" {
            switch type_tag["type"] {
            case "exist":
                segment.selectedSegmentIndex = 0
                break
            case "history":
                segment.selectedSegmentIndex = 1
                break
            default:
                segment.selectedSegmentIndex = 0
                break
            }
        }
    }
    
    func setupXibContainerViewFrame() {
        
        view.bounds.size.height = UIScreen.main.bounds.size.height * 0.3
        view.bounds.size.width = UIScreen.main.bounds.size.width * 0.8
        
        segment.translatesAutoresizingMaskIntoConstraints = false
        topConst.constant = (UIScreen.main.bounds.size.height*0.3-24-90-34-48-30)/2
        bottomConst.constant = (UIScreen.main.bounds.size.height*0.3-24-90-34-48-30)/2
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            type_tag["type"] = "exist"
            break
        case 1:
            type_tag["type"] = "history"
            break
        default:
            break
        }
    }
    
    
    @IBAction func saveTapped(_ sender: RoundButton) {
        switch sender.tag {
        case 0:
            type_tag["save"] = "without"
            break
        case 1:
            type_tag["save"] = "with"
            break
        default:
            break
        }
        delegate.saveTapped(type_tag)
    }
}
