//
//  Model.swift
//  Hospital
//
//  Created by Alex on 7/31/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift



class OPDPatient: Object {
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var age = -1
    @objc dynamic var gender = ""
    @objc dynamic var num = -1
    @objc dynamic var detail = ""
    @objc dynamic var wards = ""
    @objc dynamic var imageUri = ""
    @objc dynamic var pdfUri = ""
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
}



class Patient: Object {
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var age = -1
    @objc dynamic var gender = ""
    @objc dynamic var bed = -1
    @objc dynamic var dateOfAdmitt = ""
    @objc dynamic var progress = ""
    @objc dynamic var oneDay = ""
    @objc dynamic var conti = ""
    @objc dynamic var category = ""
    @objc dynamic var type = ""
    @objc dynamic var imageUri = ""
    @objc dynamic var wards = ""
    @objc dynamic var progressImageUri = ""
    @objc dynamic var oneDayImageUri = ""
    @objc dynamic var continueImageUri = ""
    @objc dynamic var pdfUri = ""
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
