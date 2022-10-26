//
//  UIViewController+Extension.swift
//  NoiseApp
//
//  Created by Mitchel Santillan Cruz on 10/26/22.
//

import UIKit

extension UIViewController
{
    static var identifier: String
    {
        return String(describing: self)
    }
    
    static func instantiate() -> Self
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier) as! Self 
    }
}
