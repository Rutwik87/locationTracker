//
//  Helper.swift
//  locationTracker
//
//  Created by Rutwik Shinde on 05/03/22.
//

import Foundation

extension UserDefaults {
    enum Keys: String, CaseIterable {
        case name
        case number
        case isLoggedIn
    }
    
    func resetKeys() {
        Keys.allCases.forEach { removeObject(forKey: $0.rawValue) }
    }
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}
