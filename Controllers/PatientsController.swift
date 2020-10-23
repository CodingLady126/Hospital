//
//  PatientsController.swift
//  Hospital
//
//  Created by Alex on 7/30/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import UIKit
import Floaty
import Toast_Swift
import RealmSwift


class PatientsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var wardLabel: UILabel!
    @IBOutlet weak var patientTableView: UITableView!
    @IBOutlet weak var floatBtn: Floaty!
    var ward_name: String!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var wardTopConst: NSLayoutConstraint!
    @IBOutlet weak var wardLeadingConst: NSLayoutConstraint!
    @IBOutlet weak var wardTrailingConst: NSLayoutConstraint!
    @IBOutlet weak var heightConst: NSLayoutConstraint!
    
    
    var patients: Results<Patient>? = nil
    var previewController: PDFPreviewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        patientTableView.delegate = self
        patientTableView.dataSource = self
        
        wardLabel.text = ward_name
        
        setupFloatingButton()
        setLayout()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        let realm = try! Realm()
        let predicate = NSPredicate(format: "wards = %@ AND type = %@", "\(self.ward_name!)", "exist")
        patients = realm.objects(Patient.self).filter(predicate)
        if patients?.count == 0 {
            self.view.makeToast("There is no informations!")
        }
    }
    
    
    func setLayout() {
        wardLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        wardTopConst.constant = self.view.frame.height*1.69/23.18-2
        wardLeadingConst.constant = self.view.frame.width*5.89/17.34
        wardTrailingConst.constant = self.view.frame.width*5.89/17.34
        heightConst.constant = self.view.frame.height*0.91/23.18
        
        topConstraint.constant = 24
        bottomConstraint.constant = (self.view.frame.height*0.77/23.18+24)*(-1)
        leadingConstraint.constant = self.view.frame.width*1.03/17.34
        trailingConstraint.constant = self.view.frame.width*1.03/17.34
    }
    
    
    func setupFloatingButton() {
        floatBtn.openAnimationType = .pop
        floatBtn.addItem("Back", icon: UIImage(named: "back_icon")) { (_) in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeController") as! HomeController
            vc.modalTransitionStyle = .flipHorizontal
            self.present(vc, animated: true, completion: nil)
        }
        floatBtn.addItem("History", icon: UIImage(named: "history")) { (_) in
            let realm = try! Realm()
            let predicate = NSPredicate(format: "wards = %@ AND type = %@", "\(self.ward_name!)", "history")
            self.patients = realm.objects(Patient.self).filter(predicate)
            if self.patients?.count == 0 {
                self.view.makeToast("There is no history informations!")
                self.patientTableView.reloadData()
                return
            }
            self.patientTableView.reloadData()
        }
        floatBtn.addItem("New", icon: UIImage(named: "add")) { (_) in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddController") as! AddController
            vc.modalTransitionStyle = .flipHorizontal
            vc.ward = self.ward_name
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .default, title: "Edit") { (action, indexpath) in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddController") as! AddController
            vc.modalTransitionStyle = .coverVertical
            vc.passed_patient = self.patients![indexPath.row]
            vc.ward = self.ward_name
            vc.flag = "edit"
            self.present(vc, animated: true, completion: nil)
        }
        
        editAction.backgroundColor = UIColor.orange
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            let realm = try! Realm()
            let patient = self.patients![indexPath.row]
            
            self.deletePatient(patient: patient)
            
            try! realm.write {
                realm.delete(patient)
            }
            self.patientTableView.reloadData()
        }
        
        let pdfAction = UITableViewRowAction(style: .default, title: "PDF") { (action, indexPath) in
            let selected_patient = self.patients![indexPath.row]
            if selected_patient.pdfUri.isEmpty {
                self.view.makeToast("There is no PDF documentation")
            } else {
                let fileManager = FileManager.default
                let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
                let filePath = documentsPath?.appendingPathComponent(selected_patient.pdfUri)
                self.previewController = PDFPreviewController(nibName: "PDFPreviewDialog", bundle: nil)
                self.previewController.url = filePath
                self.presentDialogViewController(self.previewController, animationPattern: .zoomInOut, backgroundViewType: .solid, dismissButtonEnabled: true, completion: nil)
            }
            
        }
        
        pdfAction.backgroundColor = UIColor.purple
        
        return [pdfAction, deleteAction, editAction]
    }
    
    
    func deletePatient(patient: Patient) {
        deleteOldFile(file_name: patient.imageUri)
        if !patient.progressImageUri.isEmpty {
            deleteOldFile(file_name: patient.progressImageUri)
        }
        if !patient.oneDayImageUri.isEmpty {
            deleteOldFile(file_name: patient.oneDayImageUri)
        }
        if !patient.continueImageUri.isEmpty {
            deleteOldFile(file_name: patient.continueImageUri)
        }
        if !patient.pdfUri.isEmpty {
            deleteOldFile(file_name: patient.pdfUri)
        }
    }
    
    func deleteOldFile(file_name: String) {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let filePath = documentsPath?.appendingPathComponent(file_name)
        do {
            try fileManager.removeItem(at: filePath!)
        } catch let error {
            print("Delete Old File Error: \(error.localizedDescription)")
        }
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patients?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = patientTableView.dequeueReusableCell(withIdentifier: "PatientCell", for: indexPath) as! PatientCell
        if self.patients != nil {
            cell.noLabel.text = "\(self.patients![indexPath.row].bed)"
            cell.nameLabel.text = self.patients![indexPath.row].name
            cell.genderLabel.text = self.patients![indexPath.row].gender
        }
        return cell
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
