//
//  Utility.swift
//  Hospital
//
//  Created by Alex on 8/3/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import Foundation


class Utility {
    
    static func getCurrentLocalTime() -> String {
        let date = Date()
        let calendar = Calendar.current
        let str_year = calendar.component(.year, from: date)
        let str_month = calendar.component(.month, from: date)
        let str_day = calendar.component(.day, from: date)
        let str_hour = calendar.component(.hour, from: date)
        let str_min = calendar.component(.minute, from: date)
        let str_sec = calendar.component(.second, from: date)
        let str_milli = calendar.component(.nanosecond, from: date)/1000000
        let str_date = "\(str_year):\(str_month):\(str_day):\(str_hour):\(str_min):\(str_sec):\(str_milli)"
        
        return str_date
    }
    
    static func getRandomImageName() -> String {
        return "\(NSUUID().uuidString).jpeg"
    }
}
