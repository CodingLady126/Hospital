//
//  OPDController.swift
//  Hospital
//
//  Created by Alex on 7/31/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import UIKit
import Floaty
import RealmSwift
import Toast_Swift


class OPDController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    @IBOutlet weak var opdTableView: UITableView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var contaierView: UIView!
    @IBOutlet weak var containerTopConst: NSLayoutConstraint!
    @IBOutlet weak var containerLeadingConst: NSLayoutConstraint!
    @IBOutlet weak var containerTrailing: NSLayoutConstraint!
    @IBOutlet weak var containerBottom: NSLayoutConstraint!
    
    @IBOutlet weak var floatBtn: Floaty!
    var ward_name = ""
    var opd_patients : Results<OPDPatient>? = nil
    
    @IBOutlet weak var searchBar: PrettySearchbar!
    var searchActive : Bool = false
    var filtered_patients : Results<OPDPatient>? = nil
    var previewController: PDFPreviewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        setLayout()
        self.titleLabel.text = self.ward_name
        setFloaty()
        
        opdTableView.delegate = self
        opdTableView.dataSource = self
        
        searchBar.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let predicate = NSPredicate(format: "name CONTAINS[c] %@", "\(searchText)")
        filtered_patients = searchText.isEmpty ? opd_patients : opd_patients!.filter(predicate)
        searchActive = true
        self.opdTableView.reloadData()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
    private func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true
    }
    
    private func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false
    }
    
    private func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
    }
    
    private func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false
    }
    
   
    override func viewWillAppear(_ animated: Bool) {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "wards = %@", "\(self.ward_name)")
        opd_patients = realm.objects(OPDPatient.self).filter(predicate)
        if opd_patients?.count == 0 {
            self.view.makeToast("There is no informations!")
            self.searchBar.isHidden = true
        }
    }
    
    
    func setFloaty() {
        floatBtn.openAnimationType = .pop
        floatBtn.addItem("Home", icon: UIImage(named: "home_icon")) { (_) in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeController") as! HomeController
            vc.modalTransitionStyle = .flipHorizontal
            self.present(vc, animated: true, completion: nil)
        }
        
        floatBtn.addItem("New", icon: UIImage(named: "add")) { (_) in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OPDNewController") as! OPDNewController
            vc.modalTransitionStyle = .coverVertical
            vc.ward = self.ward_name
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    func setLayout() {
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contaierView.translatesAutoresizingMaskIntoConstraints = false
        
        titleTopConstraint.constant = self.view.frame.height*1.69/23.18-2
        titleLeadingConstraint.constant = self.view.frame.width*5.89/17.34
        titleTrailingConstraint.constant = self.view.frame.width*5.89/17.34
        heightConstraint.constant = self.view.frame.height*0.91/23.18
        
        containerTopConst.constant = 24
        containerBottom.constant = self.view.frame.height*0.77/23.18+12
        containerLeadingConst.constant = self.view.frame.width*1.03/17.34
        containerTrailing.constant = self.view.frame.width*1.03/17.34
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .default, title: "Edit") { (action, indexPath) in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OPDNewController") as! OPDNewController
            vc.modalTransitionStyle = .coverVertical
            if self.searchActive {
                vc.opd_patient = self.filtered_patients![indexPath.row]
            } else {
                vc.opd_patient = self.opd_patients![indexPath.row]
            }
        
            vc.ward = self.ward_name
            vc.flag = "edit"
            self.present(vc, animated: true, completion: nil)
        }
        
        editAction.backgroundColor = UIColor.orange
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            let realm = try! Realm()
            
            var opd_delete = OPDPatient()
            if self.searchActive {
                opd_delete = self.filtered_patients![indexPath.row]
            } else {
                opd_delete = self.opd_patients![indexPath.row]
            }
            
            self.deleteOPDPatient(opd_patient: opd_delete)
            
            try! realm.write {
                realm.delete(opd_delete)
            }
            self.opdTableView.reloadData()
        }
        
        let pdfAction = UITableViewRowAction(style: .default, title: "PDF") { (action, indexPath) in
            var selected_patient = OPDPatient()
            if self.searchActive {
                selected_patient = self.filtered_patients![indexPath.row]
            } else {
                selected_patient = self.opd_patients![indexPath.row]
            }
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
    
    
    func deleteOPDPatient(opd_patient: OPDPatient) {
        if !opd_patient.imageUri.isEmpty {
            deleteOldFile(file_name: opd_patient.imageUri)
        }
        if !opd_patient.pdfUri.isEmpty {
            deleteOldFile(file_name: opd_patient.pdfUri)
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if searchActive {
            count = filtered_patients!.count
        } else {
            count = opd_patients?.count ?? 0
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = opdTableView.dequeueReusableCell(withIdentifier: "OPDCell", for: indexPath) as! OPDCell
        if self.opd_patients != nil {
            if searchActive {
                cell.numLabel.text = "\(self.filtered_patients![indexPath.row].num)"
                cell.nameLabel.text = self.filtered_patients![indexPath.row].name
                cell.genderLabel.text = self.filtered_patients![indexPath.row].gender
                cell.ageLabel.text = "\(self.filtered_patients![indexPath.row].age)"
            } else {
                cell.numLabel.text = "\(self.opd_patients![indexPath.row].num)"
                cell.nameLabel.text = self.opd_patients![indexPath.row].name
                cell.genderLabel.text = self.opd_patients![indexPath.row].gender
                cell.ageLabel.text = "\(self.opd_patients![indexPath.row].age)"
            }
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
