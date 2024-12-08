//
//  Extensions.swift
//  ice_warp
//
//  Created by Anjali Pandey on 08/12/24.
//

import Foundation

extension String {
 
    func isValidEmail() -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
}
