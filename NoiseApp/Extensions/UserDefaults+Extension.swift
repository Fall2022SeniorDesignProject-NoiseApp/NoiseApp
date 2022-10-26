//
//  UserDefaults+Extension.swift
//  NoiseApp
//
//  Created by Mitchel Santillan Cruz on 10/26/22.
//

import Foundation

extension UserDefaults
{
    private enum UserDefaultsKeys: String
    {
        case hasOnboarded
    }
    
    var hasOnboarded: Bool
    {
        get
        {
            bool(forKey: UserDefaultsKeys.hasOnboarded.rawValue)
        }
        
        set
        {
            setValue(newValue, forKey: UserDefaultsKeys.hasOnboarded.rawValue)
        }
    }
}
