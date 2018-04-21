//
//  TALoginVC.swift
//  Roome
//
//  Created by Tareq Safia on 4/20/18.
//  Copyright © 2018 Tareq Safia. All rights reserved.
//

import UIKit

class TALoginVC: UIViewController {
    
    @IBOutlet weak var txt_email: UITextField!
    @IBOutlet weak var txt_password: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        txt_email.text = "tareq.safia@gmail.com"
        txt_password.text = "123456"
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
    }
    
    //MARK: Login Function
    @IBAction func func_login(_ sender: UIButton) {
        self.isInterntConnected()
        
        guard let email = txt_email.text , !email.isEmpty else {
            self.showOkAlert(title: "", message: "please enter email")
            return
        }
        
        guard let password = txt_password.text , !password.isEmpty else {
            self.showOkAlert(title: "", message: "please enter password")
            return
        }
        
        self.showIndicator()
        MyApi.api.func_login(email, password) { (message, status) in
            self.hideIndicator()
            if !status {
                self.showOkAlert(title: "", message: message)
                return
            }
            
            Auth_User.func_goToApp()
        }
    }
    
    //MARK: Signup Function
    @IBAction func func_signup(_ sender: UIButton) {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let vc : TARegisterVC = AppDelegate.Storyboard.instanceVC()
        appdelegate.window?.rootViewController = vc
    }
    
    //MARK: Facebook Login Function
    @IBAction func func_facebook(_ sender: UIButton) {
    }
    
    //MARK: Twitter Login Function
    @IBAction func func_twitter(_ sender: UIButton) {
    }
}
