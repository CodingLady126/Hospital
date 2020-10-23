//
//  AddController.swift
//  Hospital
//
//  Created by Alex on 7/30/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import UIKit
import Material
import Floaty
import DatePickerDialog
import Toast_Swift
import LSDialogViewController
import RealmSwift
import Photos
import PDFGenerator



class AddController: UIViewController, UITextFieldDelegate, SaveTappedDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DrawDelegate {
   
    
    @IBOutlet weak var nameTextField: ErrorTextField!
    @IBOutlet weak var ageTextField: ErrorTextField!
    @IBOutlet weak var genderTextField: ErrorTextField!
    @IBOutlet weak var bedNumTextField: ErrorTextField!
    @IBOutlet weak var dateTextField: ErrorTextField!
    
    @IBOutlet weak var progressTextView: PrettyTextView!
    @IBOutlet weak var oneDayTextView: PrettyTextView!
    @IBOutlet weak var continueTextView: PrettyTextView!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var submitBtn: RoundButton!
    
    @IBOutlet weak var floatyBtn: Floaty!
    @IBOutlet weak var categorySegment: UISegmentedControl!
    
    
    var nameValid = false; var ageValid = false; var genderValid = false; var bedValid = false; var dateValid = false
    var dialogController: DialogController!
    
    var catefory = "Labs"
    var image_url = ""
    var image_selected = false
    var image_changed = false
    var ward = ""
    var passed_patient = Patient()
    var flag: String = ""
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var topConst: NSLayoutConstraint!
    @IBOutlet weak var leadingConst: NSLayoutConstraint!
    @IBOutlet weak var trailingConst: NSLayoutConstraint!
    @IBOutlet weak var bottomConst: NSLayoutConstraint!
    
    var imagePicker : UIImagePickerController?
    
    @IBOutlet weak var progressImageView: UIImageView!
    @IBOutlet weak var oneDayImageView: UIImageView!
    @IBOutlet weak var continueImageView: UIImageView!
    @IBOutlet weak var progressPencil: UIButton!
    @IBOutlet weak var oneDayPencil: UIButton!
    @IBOutlet weak var continuePencil: UIButton!
    @IBOutlet weak var bodyView: UIScrollView!
    
    var drawController: DrawController!
    var previewController: PDFPreviewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setTextField()
        
        setFloaty()
        
        // Disable status of submit button //
        submitBtn.isEnabled = false
        submitBtn.alpha = 0.5
        
        setLayout()
        setRealm()
        
        if flag == "edit" {
            populatePatientData()
        }
        
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        
        setPencilHidden(bool: false)
    }
    
    
    func hideKeyborad() {
        progressTextView.resignFirstResponder()
        oneDayTextView.resignFirstResponder()
        continueTextView.resignFirstResponder()
    }
    
    @IBAction func progressPencilTapped(_ sender: Any) {
        hideKeyborad()
        drawController = DrawController(nibName: "Draw", bundle: nil)
        drawController.which_part = "progress"
        drawController.delegate = self
        self.presentDialogViewController(drawController, animationPattern: .zoomInOut, backgroundViewType: .solid, dismissButtonEnabled: true, completion: nil)
    }
    
    
    @IBAction func oneDayPencilTapped(_ sender: Any) {
        hideKeyborad()
        drawController = DrawController(nibName: "Draw", bundle: nil)
        drawController.which_part = "oneday"
        drawController.delegate = self
        self.presentDialogViewController(drawController, animationPattern: .zoomInOut, backgroundViewType: .solid, dismissButtonEnabled: true, completion: nil)
        
    }
    
    @IBAction func continuePencilTapped(_ sender: Any) {
        hideKeyborad()
        drawController = DrawController(nibName: "Draw", bundle: nil)
        drawController.which_part = "continue"
        drawController.delegate = self
        self.presentDialogViewController(drawController, animationPattern: .zoomInOut, backgroundViewType: .solid, dismissButtonEnabled: true, completion: nil)
    }
    
    func doneButtonTapped(_ sender: Any) {
        self.dismissDialogViewController(.fadeInOut)
        let data = sender as! Dictionary<String, Any>
        switch data["key"] as! String {
        case "progress":
            progressImageView.image = (data["image"] as? UIImage)
            progressTextView.text = (data["text"] as! String)
            break
        case "oneday":
            oneDayImageView.image = (data["image"] as? UIImage)
            oneDayTextView.text = (data["text"] as! String)
            break
        case "continue":
            continueImageView.image = (data["image"] as? UIImage)
            continueTextView.text = (data["text"] as! String)
            break
        default:
            break
        }
    }
    
    
    func setPencilHidden(bool: Bool) {
        progressPencil.isHidden = bool
        oneDayPencil.isHidden = bool
        continuePencil.isHidden = bool
    }
    
    
    func populatePatientData() {
        self.nameTextField.text = self.passed_patient.name
        self.ageTextField.text = "\(self.passed_patient.age)"
        self.genderTextField.text = self.passed_patient.gender
        self.bedNumTextField.text = "\(self.passed_patient.bed)"
        self.dateTextField.text = self.passed_patient.dateOfAdmitt
        self.progressTextView.text = self.passed_patient.progress
        self.oneDayTextView.text = self.passed_patient.oneDay
        self.continueTextView.text = self.passed_patient.conti
        switch self.passed_patient.category {
        case "Labs":
            self.categorySegment.selectedSegmentIndex = 0
            self.catefory = "Lab"
            break
        case "Vital Sign":
            self.categorySegment.selectedSegmentIndex = 1
            self.catefory = "Vital Sign"
            break
        case "Investigations":
            self.categorySegment.selectedSegmentIndex = 2
            self.catefory = "Investigations"
            break
        default:
            self.categorySegment.selectedSegmentIndex = 0
            self.catefory = "Lab"
            break
        }
        self.image_url = self.passed_patient.imageUri
        self.image_selected = true
        loadIamge(uri: self.image_url, imageView: self.imageView)
        
        if !passed_patient.progressImageUri.isEmpty {
            loadIamge(uri: self.passed_patient.progressImageUri, imageView: self.progressImageView)
        }
        if !passed_patient.oneDayImageUri.isEmpty {
            loadIamge(uri: self.passed_patient.oneDayImageUri, imageView: self.oneDayImageView)
        }
        if !passed_patient.continueImageUri.isEmpty {
            loadIamge(uri: self.passed_patient.continueImageUri, imageView: self.continueImageView)
        }
        
        self.submitBtn.isEnabled = true
        self.submitBtn.alpha = 1
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
    
    
    
    func setRealm() {
        let realm = try! Realm()
        
        // Get our Realm file's parent directory
        let folderPath = realm.configuration.fileURL!.deletingLastPathComponent().path
        print(folderPath)
        
        // Disable file protection for this directory
        try! FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.none], ofItemAtPath: folderPath)
    }
    
    
    func setLayout() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        topConst.constant = self.view.frame.height*2.95/23.18
        bottomConst.constant = (-1)*(self.view.frame.height*0.77/23.18+6)
        leadingConst.constant = self.view.frame.width*1.03/17.34+6
        trailingConst.constant = self.view.frame.width*1.03/17.34+6
    }
    
    
    func setFloaty() {
        floatyBtn.buttonImage = UIImage(named: "home_white_icon")
        floatyBtn.openAnimationType = .pop
        floatyBtn.addItem("Back", icon: UIImage(named: "back_icon")) { (_) in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PatientsController") as! PatientsController
            vc.ward_name = self.ward
            vc.modalTransitionStyle = .partialCurl
            self.present(vc, animated: true, completion: nil)
        }
        
        floatyBtn.addItem("iPencil", icon: UIImage(named: "iPencil")) { (_) in
            let reachability = ApplePencilReachability()
            if !reachability.isPencilAvailable {
                self.setPencilHidden(bool: true)
                self.view.makeToast("You can not use iPencil. Please connect your iPencil.")
            } else {
                self.setPencilHidden(bool: false)
                self.view.makeToast("You have chosen iPencil mode.")
            }
        }
        
        floatyBtn.addItem("Home", icon: UIImage(named: "home_icon")) { (_) in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeController") as! HomeController
            vc.modalTransitionStyle = .partialCurl
            self.present(vc, animated: true, completion: nil)
        }
    }
    

    func setTextField() {
        nameTextField.setLeftView(img_name: "name_icon")
        nameTextField.isClearIconButtonEnabled = true
        nameTextField.clearButtonMode = .whileEditing
        
        ageTextField.setLeftView(img_name: "age_icon")
        genderTextField.setLeftView(img_name: "gender_icon")
        genderTextField.autocapitalizationType = .sentences

        bedNumTextField.setLeftView(img_name: "num_icon")
        dateTextField.setLeftView(img_name: "date_icon")

        dateTextField.isClearIconButtonEnabled = true
        dateTextField.clearButtonMode = .whileEditing

        nameTextField.delegate = self
        ageTextField.delegate = self
        genderTextField.delegate = self
        bedNumTextField.delegate = self
        dateTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == nil || textField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            (textField as! ErrorTextField).isErrorRevealed = true
            if textField == nameTextField {
                nameValid = false
            } else if textField == ageTextField {
                ageValid = false
            } else if textField == genderTextField {
                genderValid = false
            } else if textField == bedNumTextField {
                bedValid = false
            } else {
                dateValid = false
            }
            self.submitBtn.isEnabled = false
            self.submitBtn.alpha = 0.5
            return
        }
        if textField == ageTextField || textField == bedNumTextField {
            if textField.text!.count > 2 {
                (textField as! ErrorTextField).isErrorRevealed = true
                switch textField {
                case ageTextField:
                    ageValid = false
                    break
                case bedNumTextField:
                    bedValid = false
                    break
                default:
                    break
                }
                self.submitBtn.isEnabled = false
                self.submitBtn.alpha = 0.5
                return
            }
        }
        if textField == genderTextField {
            genderTextField.error = "Max 1"
            if textField.text!.count > 1 {
                (textField as! ErrorTextField).isErrorRevealed = true
                genderValid = false
                self.submitBtn.isEnabled = false
                self.submitBtn.alpha = 0.5
                return
            }
            if !genderTextField.text!.hasPrefix("M") && !genderTextField.text!.hasPrefix("F") {
                genderValid = false
                genderTextField.error = "Invalid"
                genderTextField.isErrorRevealed = true
                self.submitBtn.isEnabled = false
                self.submitBtn.alpha = 0.5
                return
            }
        }
        
        if textField == nameTextField {
            nameValid = true
        } else if textField == ageTextField {
            ageValid = true
        } else if textField == genderTextField {
            genderValid = true
        } else if textField == bedNumTextField {
            bedValid = true
        } else {
            dateValid = true
        }
        
        if nameValid && ageValid && genderValid && bedValid && dateValid {
            self.submitBtn.isEnabled = true
            self.submitBtn.alpha = 1
        }
    }
    

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        (textField as! ErrorTextField).isErrorRevealed = false
        return true
    }
    
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        (textField as! ErrorTextField).isErrorRevealed = false
        return true
    }
    
    
    @IBAction func datePickerTapped(_ sender: Any) {
        DatePickerDialog().show("Please choose your date!", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: Date(), datePickerMode: .date) { (date) in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let str_date = formatter.string(from: dt)
                self.dateTextField.text = str_date
                self.dateTextField.isErrorRevealed = false
                self.dateValid = true
                
                if self.nameValid && self.ageValid && self.genderValid && self.bedValid && self.dateValid {
                    self.submitBtn.isEnabled = true
                    self.submitBtn.alpha = 1
                }
            }
        }
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
    
    
    @IBAction func submitTapped(_ sender: Any) {
//        if (!validate(textView: progressTextView) && !image_validate(imageView: progressImageView)) || (!validate(textView: oneDayTextView) && !image_validate(imageView: oneDayImageView)) || (!validate(textView: continueTextView) && !image_validate(imageView: continueImageView)) {
//            self.view.makeToast("Please check some empty boxs")
//            return
//        }
//        if !image_selected {
//            self.view.makeToast("Please choose a image")
//            return
//        }
        
        dialogController = DialogController(nibName: "Dialog", bundle: nil)
        dialogController.delegate = self
        if flag == "edit" {
            dialogController.flag = "edit"
            dialogController.type_tag["type"] = self.passed_patient.type
        }

        self.presentDialogViewController(dialogController, animationPattern: .zoomInOut, backgroundViewType: .solid, dismissButtonEnabled: true, completion: nil)
    }
    
    
    func saveTapped(_ sender: Any) {
        
        let realm = try! Realm()
        let patient = Patient()
        
        let type_tag = sender as! Dictionary<String, Any>
        let type = type_tag["type"] as! String
        let save_type = type_tag["save"] as! String
        
        if flag == "edit" {
            if image_changed {
                deleteOldFile(file_name: passed_patient.imageUri)
            }
            if !passed_patient.progressImageUri.isEmpty {
                deleteOldFile(file_name: passed_patient.progressImageUri)
            }
            if !passed_patient.oneDayImageUri.isEmpty {
                deleteOldFile(file_name: passed_patient.oneDayImageUri)
            }
            if !passed_patient.continueImageUri.isEmpty {
                deleteOldFile(file_name: passed_patient.continueImageUri)
            }
            if !passed_patient.pdfUri.isEmpty {
                deleteOldFile(file_name: passed_patient.pdfUri)
            }
            
            patient.id = self.passed_patient.id
        } else {
            if let ret_id = realm.objects(Patient.self).sorted(byKeyPath: "id", ascending: false).first?.id {
                print(ret_id)
                patient.id = ret_id + 1
            } else {
                patient.id = 0
            }
        }
        
        patient.name = self.nameTextField.text!
        patient.age = Int(self.ageTextField.text!) ?? -1
        patient.gender = self.genderTextField.text!
        patient.bed = Int(self.bedNumTextField.text!) ?? -1
        patient.dateOfAdmitt = self.dateTextField.text!
        patient.progress = self.progressTextView.text!
        patient.oneDay = self.oneDayTextView.text!
        patient.conti = self.continueTextView.text!
        patient.category = self.catefory
        patient.type = type
        patient.imageUri = self.image_url
        patient.wards = self.ward
        patient.progressImageUri = self.setIamgeNameOfHomeDirectory(image: self.progressImageView.image)
        patient.oneDayImageUri = self.setIamgeNameOfHomeDirectory(image: self.oneDayImageView.image)
        patient.continueImageUri = self.setIamgeNameOfHomeDirectory(image: self.continueImageView.image)
        if save_type == "with" {
            let filename =  "\(self.ward)-\(self.nameTextField.text!)-\(self.bedNumTextField.text!)-\(Utility.getCurrentLocalTime()).pdf"
            patient.pdfUri = filename
            savePDF(file_name: filename)
        }
        
        try! realm.write {
            realm.add(patient, update: .modified)
//            realm.deleteAll()
        }
        
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PatientsController") as! PatientsController
        vc.ward_name = self.ward
        vc.modalTransitionStyle = .crossDissolve
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
        
        let v1 = self.bodyView
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
    
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            catefory = "Labs"
            break
        case 1:
            catefory = "Vital Sign"
            break
        case 2:
            catefory = "Investigations"
            break
        default:
            catefory = "Labs"
            break
        }
    }
    
    
    @IBAction func cameraTapped(_ sender: Any) {
        if imagePicker != nil {
            image_changed = true
            imagePicker!.sourceType = .camera
            present(imagePicker!, animated: true, completion: nil)
        }
    }
    
    @IBAction func galleryTapped(_ sender: Any) {
        if imagePicker != nil {
            image_changed = true
            imagePicker?.sourceType = .photoLibrary
            present(imagePicker!, animated: true, completion: nil)
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        image_changed = false
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            
            //obtaining saving path
            let fileManager = FileManager.default
            let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            
            let imageName: String = Utility.getRandomImageName()
            let imagePath = documentsPath?.appendingPathComponent(imageName)
    
            // extract image from the picker and save it
            let imageData = image.jpegData(compressionQuality: 0.1)
            try! imageData?.write(to: imagePath!)
            
            imageView.image = image
            self.image_selected = true
            self.image_url = imageName
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
