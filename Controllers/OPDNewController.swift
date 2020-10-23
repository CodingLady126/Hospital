//
//  OPDNewController.swift
//  Hospital
//
//  Created by Alex on 7/31/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import UIKit
import Floaty
import Material
import Toast_Swift
import RealmSwift
import PDFGenerator


class OPDNewController: UIViewController, UITextFieldDelegate, DrawDelegate {
    
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var trailingConst: NSLayoutConstraint!
    @IBOutlet weak var leadingConst: NSLayoutConstraint!
    @IBOutlet weak var topConst: NSLayoutConstraint!
    @IBOutlet weak var bottomConst: NSLayoutConstraint!
    @IBOutlet weak var floatBtn: Floaty!
    
    var ward: String = ""
    
    @IBOutlet weak var nameTextField: ErrorTextField!
    @IBOutlet weak var ageTextField: ErrorTextField!
    @IBOutlet weak var genderTextField: ErrorTextField!
    @IBOutlet weak var numTextField: ErrorTextField!
    @IBOutlet weak var detailTextView: PrettyTextView!
    
    @IBOutlet weak var submitBtn: RoundButton!
    @IBOutlet weak var savePDFBtn: RoundButton!
    
    var nameValid = false
    var ageValid = false
    var genderValid = false
    var numValid = false
    
    var opd_patient = OPDPatient()
    var flag = ""
    
    @IBOutlet weak var iPencilBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bodyVew: UIView!
    
    var drawController: DrawController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setLayout()
        setTextField()
        setFloaty()
        
        submitBtn.isEnabled = false
        submitBtn.alpha = 0.5
        savePDFBtn.isEnabled = false
        savePDFBtn.alpha = 0.5
        
        setRealm()
        
        if flag == "edit" {
            populate()
        }
    }
    
    func populate() {
        nameTextField.text = opd_patient.name
        genderTextField.text = opd_patient.gender
        ageTextField.text = "\(opd_patient.age)"
        numTextField.text = "\(opd_patient.num)"
        detailTextView.text = opd_patient.detail
        if !opd_patient.imageUri.isEmpty {
            loadIamge(uri: opd_patient.imageUri, imageView: self.imageView)
        }
        
        submitBtn.isEnabled = true
        submitBtn.alpha = 1
        savePDFBtn.isEnabled = true
        savePDFBtn.alpha = 1
    }
    
    
    func loadIamge(uri: String, imageView: UIImageView) {
        // obtaining saving path
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        
        let imagePath = documentsPath?.appendingPathComponent(uri)
        do {
            let imageData = try Data(contentsOf: imagePath!)
            imageView.image = UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
    }
    
    
    @IBAction func ipencilTapped(_ sender: Any) {
        detailTextView.resignFirstResponder()
        drawController = DrawController(nibName: "Draw", bundle: nil)
        drawController.which_part = "opd"
        drawController.delegate = self
        self.presentDialogViewController(drawController, animationPattern: .zoomInOut, backgroundViewType: .solid, dismissButtonEnabled: true, completion: nil)
    }
    
    
    func doneButtonTapped(_ sender: Any) {
        self.dismissDialogViewController(.fadeInOut)
        let data = sender as! Dictionary<String, Any>
        detailTextView.text = (data["text"] as! String)
        imageView.image = (data["image"] as! UIImage)
    }
    
    
    func setRealm() {
        let realm = try! Realm()
        
        // Get our Realm file's parent directory
        let folderPath = realm.configuration.fileURL!.deletingLastPathComponent().path
        print(folderPath)
        
        // Disable file protection for this directory
        try! FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.none], ofItemAtPath: folderPath)
    }
    
    
    func setFloaty() {
        
        floatBtn.addItem("Back", icon: UIImage(named: "back_icon")) { (_) in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OPDController") as! OPDController
            vc.modalTransitionStyle = .flipHorizontal
            vc.ward_name = self.ward
            self.present(vc, animated: true, completion: nil)
        }
        
        floatBtn.addItem("iPencil", icon: UIImage(named: "iPencil")) { (_) in
            let reachability = ApplePencilReachability()
            if !reachability.isPencilAvailable {
                self.iPencilBtn.isHidden = true
                self.view.makeToast("You can not use iPencil. Please connect your iPencil.")
            } else {
                self.iPencilBtn.isHidden = false
                self.view.makeToast("You have chosen iPencil mode.")
            }
        }
    }
    
    func setTextField() {
        nameTextField.setLeftView(img_name: "name_icon")
        nameTextField.isClearIconButtonEnabled = true
        nameTextField.clearButtonMode = .whileEditing
        
        ageTextField.setLeftView(img_name: "age_icon")
        genderTextField.setLeftView(img_name: "gender_icon")
        genderTextField.autocapitalizationType = .sentences
        
        numTextField.setLeftView(img_name: "num_icon")
        
        nameTextField.delegate = self
        ageTextField.delegate = self
        genderTextField.delegate = self
        numTextField.delegate = self
    }
    
    
    func setLayout() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        topConst.constant = self.view.frame.height*2.95/23.18
        bottomConst.constant = self.view.frame.height*0.77/23.18+6
        leadingConst.constant = self.view.frame.width*1.03/17.34+6
        trailingConst.constant = self.view.frame.width*1.03/17.34+6
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == nil || textField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            switch textField {
            case nameTextField:
                nameValid = false
                break
            case ageTextField:
                ageValid = false
                break
            case genderTextField:
                genderValid = false
                break
            case numTextField:
                numValid = false
                break
            default:
                break
            }
            (textField as! ErrorTextField).isErrorRevealed = true
            self.submitBtn.isEnabled = false
            submitBtn.alpha = 0.5
            savePDFBtn.isEnabled = false
            savePDFBtn.alpha = 0.5
            return
        }
        switch textField {
        case ageTextField:
            if textField.text!.count > 2 {
                (textField as! ErrorTextField).isErrorRevealed = true
                ageValid = false
                self.submitBtn.isEnabled = false
                self.submitBtn.alpha = 0.5
                savePDFBtn.isEnabled = false
                savePDFBtn.alpha = 0.5
                return
            }
            break
        case genderTextField:
            genderTextField.error = "Max 1"
            if textField.text!.count > 1 {
                (textField as! ErrorTextField).isErrorRevealed = true
                genderValid = false
                self.submitBtn.isEnabled = false
                self.submitBtn.alpha = 0.5
                savePDFBtn.isEnabled = false
                savePDFBtn.alpha = 0.5
                return
            }
            if !textField.text!.hasPrefix("M") && !textField.text!.hasPrefix("F") {
                genderValid = false
                genderTextField.error = "Invalid"
                genderTextField.isErrorRevealed = true
                self.submitBtn.isEnabled = false
                self.submitBtn.alpha = 0.5
                savePDFBtn.isEnabled = false
                savePDFBtn.alpha = 0.5
                return
            }
            break
        case numTextField:
            if textField.text!.count > 3 {
                (textField as! ErrorTextField).isErrorRevealed = true
                numValid = false
                self.submitBtn.isEnabled = false
                self.submitBtn.alpha = 0.5
                savePDFBtn.isEnabled = false
                savePDFBtn.alpha = 0.5
                return
            }
            break
        default:
            break
        }
        
        switch textField {
        case nameTextField:
            nameValid = true
            break
        case ageTextField:
            ageValid = true
            break
        case genderTextField:
            genderValid = true
            break
        case numTextField:
            numValid = true
            break
        default:
            break
        }
        if nameValid && ageValid && genderValid && numValid {
            self.submitBtn.isEnabled = true
            self.submitBtn.alpha = 1
            savePDFBtn.isEnabled = true
            savePDFBtn.alpha = 1
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        (textField as! ErrorTextField).isErrorRevealed = false
        return true
    }
    
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        (textField as! ErrorTextField).isErrorRevealed = false
        return true
    }
    
    
    func validate(textView: UITextView) -> Bool {
        guard let text = textView.text,
            !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
                return false
        }
        return true
    }
    
    func image_validate(imageView: UIImageView) -> Bool {
        let image_n = imageView.image
        if image_n == nil { return false }
        return true
    }
    
    
    @IBAction func submitTapped(_ sender: RoundButton) {
        
        if !validate(textView: detailTextView) && !image_validate(imageView: self.imageView) {
            self.view.makeToast("Please check some empty boxs")
            return
        }
        
        let realm = try! Realm()
        let opd_patient = OPDPatient()
        
        if flag == "edit" {
            if !self.opd_patient.imageUri.isEmpty {
                deleteOldFile(file_name: self.opd_patient.imageUri)
            }
            if !self.opd_patient.pdfUri.isEmpty {
                deleteOldFile(file_name: self.opd_patient.pdfUri)
            }
            opd_patient.id = self.opd_patient.id
        } else {
            if let ret_id = realm.objects(OPDPatient.self).sorted(byKeyPath: "id", ascending: false).first?.id {
                print(ret_id)
                opd_patient.id = ret_id + 1
            } else {
                opd_patient.id = 0
            }
        }
    
        opd_patient.name = self.nameTextField.text!
        opd_patient.age = Int(self.ageTextField.text!) ?? -1
        opd_patient.gender = self.genderTextField.text!
        opd_patient.num = Int(self.numTextField.text!) ?? -1
        opd_patient.detail = self.detailTextView.text!
        opd_patient.wards = self.ward
        opd_patient.imageUri = self.setIamgeNameOfHomeDirectory(image: self.imageView.image)
        if sender.tag != 0 {
            let filename =  "\(self.ward)-\(self.nameTextField.text!)-\(Utility.getCurrentLocalTime()).pdf"
            savePDF(file_name: filename)
            opd_patient.pdfUri = filename
        }
        
        try! realm.write {
            realm.add(opd_patient, update: .modified)
        }
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OPDController") as! OPDController
        vc.modalTransitionStyle = .crossDissolve
        vc.ward_name = self.ward
        self.present(vc, animated: true, completion: nil)
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
    
    
    
    func savePDF(file_name: String) {
        
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let filePath = documentsPath?.appendingPathComponent(file_name)
        
        let v1 = self.bodyVew
        v1!.backgroundColor = UIColor(red: 224/255, green: 240/255, blue: 248/255, alpha: 1)
        
        do {
            try PDFGenerator.generate(v1!, to: filePath!)
        } catch (let error) {
            print("Generate PDF Error: \(error)")
        }
    }
    
    
    func setIamgeNameOfHomeDirectory(image: UIImage?) -> String {
        var imageNameReturn = ""
        if image != nil {
            let fileManager = FileManager.default
            let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            
            let imageName: String = Utility.getRandomImageName()
            let imagePath = documentsPath?.appendingPathComponent(imageName)
            
            // extract image from the picker and save it
            let imageData = image!.jpegData(compressionQuality: 0.1)
            try! imageData?.write(to: imagePath!)
            imageNameReturn = imageName
        }
        return imageNameReturn
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
