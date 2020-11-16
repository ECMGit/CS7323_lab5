//
//  Switcher.swift
//  CS7323Lab5
//
//  Created by 沈俊豪 on 11/14/20.
//  Reference: https://medium.com/@paul.allies/ios-swift4-login-logout-branching-4cdbc1f51e2c

import Foundation
import UIKit

class Switcher {
    static func updateRootVC(){
        
        let status = UserDefaults.standard.bool(forKey: "status")
        var rootVC : UIViewController?
            print(status)
        if(status == true){
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "canvas") as! PaintingPaintingViewController
        }else{
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginvc") as! LoginViewController
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = rootVC
        
    }
}
