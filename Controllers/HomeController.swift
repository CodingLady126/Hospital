//
//  ViewController.swift
//  Hospital
//
//  Created by Alex on 7/29/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import UIKit

class HomeController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    @IBOutlet weak var wardsTableView: UITableView!
    let wards: [String]! = [
        "Surgery", "Sx M", "Sx F", "Sx OPD", "OR", "Med", "Med M", "Med F", "Med OPD", "Obgyn", "Obgyn OPD", "Orthopedics", "Pediatrics", "Pediatrics OPD", "X-ray",
        "Psychiatry", "ER", "Anes", "Eye", "ENT", "Neurology", "Miscellaneous", "Add"
    ]
   
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wardsTableView.delegate = self
        wardsTableView.dataSource = self
        
        setLayout()
    }
    
    
    func setLayout() {
        wardsTableView.translatesAutoresizingMaskIntoConstraints = false
        topConstraint.constant = self.view.frame.height*2.95/23.18
        bottomConstraint.constant = self.view.frame.height*0.77/23.18+24
        leadingConstraint.constant = self.view.frame.width*1.03/17.34+16
        trailingConstraint.constant = self.view.frame.width*1.03/17.34+16
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.wards[indexPath.row].contains("OPD") {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OPDController") as! OPDController
            vc.modalTransitionStyle = .coverVertical
            vc.ward_name = self.wards[indexPath.row]
            self.present(vc, animated: true, completion: nil)
        } else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PatientsController") as! PatientsController
            vc.modalTransitionStyle = .partialCurl
            vc.ward_name = self.wards[indexPath.row]
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = wardsTableView.dequeueReusableCell(withIdentifier: "WardsCell", for: indexPath) as! WardsCell
        cell.wardNameLabel.text = wards[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }


    override var prefersStatusBarHidden: Bool {
        return true
    }
}

