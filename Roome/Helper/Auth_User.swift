

import Foundation
import UIKit

struct Auth_User {

    static var Email : String {
        get {
            let ud = UserDefaults.standard
            return ud.value(forKey: "email") as? String ?? ""
        }
        set(token) {
            let ud = UserDefaults.standard
            ud.set(token, forKey: "email")
        }
    }
    
    static var Name : String {
        get {
            let ud = UserDefaults.standard
            return ud.value(forKey: "name") as? String ?? ""
        }
        set(token) {
            let ud = UserDefaults.standard
            ud.set(token, forKey: "name")
        }
    }
   
    
    static var AccessToken : String {
        get {
            let ud = UserDefaults.standard
            return ud.value(forKey: "AccessToken") as? String ?? ""
        }
        set(token) {
            let ud = UserDefaults.standard
            ud.set(token, forKey: "AccessToken")
        }
    }
    
    static var TokenType : String {
        get {
            let ud = UserDefaults.standard
            return ud.value(forKey: "TokenType") as? String ?? ""
        }
        set(token) {
            let ud = UserDefaults.standard
            ud.set(token, forKey: "TokenType")
        }
    }
  
    
    static func func_goToApp() {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let vc : UINavigationController = AppDelegate.Storyboard.instanceVC()
        appdelegate.window?.rootViewController = vc
        UIView.transition(with: appdelegate.window!, duration: 1, options: .transitionCrossDissolve, animations: nil, completion: nil)
    }
 
}
