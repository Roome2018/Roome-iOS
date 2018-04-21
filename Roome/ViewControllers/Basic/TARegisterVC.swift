//
//  TARegisterVC.swift
//  Roome
//
//  Created by Tareq Safia on 4/20/18.
//  Copyright © 2018 Tareq Safia. All rights reserved.
//

import UIKit
import IBAnimatable
class TARegisterVC: UIViewController {

    @IBOutlet weak var btn_signup: AnimatableButton!
    @IBOutlet weak var txt_name: UITextField!
    @IBOutlet weak var txt_email: UITextField!
    @IBOutlet weak var txt_mobile: UITextField!
    @IBOutlet weak var txt_password: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        txt_name.text = "tareq"
        txt_email.text = "tareq.safia@gmail.com"
        txt_password.text = "123456"
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.func_setStyle()
    }
    
    //MARK: Set Style
    func func_setStyle() {
        btn_signup.setRounded(radius: 10)
        btn_signup.applyGradient(colours: ["17EAD9".color,"6078EA".color], gradientOrientation: .horizontal)
    }
    
    
    //MARK: Signup function
    @IBAction func func_signup(_ sender: UIButton) {
        self.isInterntConnected()
        
        guard let name = txt_name.text , !name.isEmpty else {
            self.showOkAlert(title: "", message: "please enter your name")
            return
        }
        
        guard let email = txt_email.text , !email.isEmpty else {
            self.showOkAlert(title: "", message: "please enter email")
            return
        }
        
        
        guard let mobile = txt_mobile.text , !mobile.isEmpty else {
            self.showOkAlert(title: "", message: "please enter your mobile")
            return
        }
        
        guard let password = txt_password.text , !password.isEmpty else {
            self.showOkAlert(title: "", message: "please enter password")
            return
        }
        
        self.showIndicator()

        MyApi.api.func_signup(name, email, password , mobile) { (message, status) in
            self.hideIndicator()
            if !status {
                self.showOkAlert(title: "", message: message)
                return
            }
            
            Auth_User.func_goToApp()
        }
    }
    
    
    //MARK: Back To Login
    @IBAction func func_backToLogin(_ sender: UIButton) {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let vc : TALoginVC = AppDelegate.Storyboard.instanceVC()
        appdelegate.window?.rootViewController = vc
    }
    
}
