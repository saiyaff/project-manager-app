//
//  UtilityService.swift
//  project-manager-app
//
//  Created by Saiyaff Farouk on 5/24/19.
//  Copyright © 2019 Saiyaff Farouk. All rights reserved.
//

import Foundation
import UIKit

class UtilityService {
    
    static func showErrorMessage(_ message: String) -> UIAlertController {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alert;
    }
    
    static func convertDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        dateFormatter.dateFormat = "MMM-dd-yyyy"
        let dateStr = dateFormatter.string(from: date)
        return dateStr
    }
    
}
