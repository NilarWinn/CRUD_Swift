//
//  LoginViewController.swift
//  MVC-Swift
//
//  Created by NilarWin on 10/08/2022.
//
import UIKit
import SwiftValidator
import Alamofire
import SVProgressHUD
import SwiftyJSON

class LoginVC : UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailError: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordError: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var visibleIcon: UIButton!
    let validator = Validator()
    var iconClick = true
    var buttonClick = false
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginVC.hideKeyboard)))
        
        let token:String = UserDefaults.standard.string(forKey: "token") ?? ""
        if token.count > 0 {
            checkToken()
        }
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true
        loginButton.layer.cornerRadius = 5
        setUpLayerDesign()
        
        validator.styleTransformers(success: { (validationRule) -> Void in
            validationRule.errorLabel?.isHidden = true
            validationRule.errorLabel?.text = ""
            let textfield = validationRule.field as! UITextField
            textfield.layer.borderColor = UIColor.black.cgColor
            
        }, error: {(validationError) -> Void in
            validationError.errorLabel?.isHidden = false
            validationError.errorLabel?.text = validationError.errorMessage
            let textfield = validationError.field as! UITextField
            textfield.layer.borderColor = UIColor.red.cgColor
        })
        
        validator.registerField(emailTextField, errorLabel: emailError, rules: [RequiredRule(message: "Email is Required Field"), EmailRule(message: "Invalid email")])
        validator.registerField(passwordTextField, errorLabel: passwordError, rules: [RequiredRule(message: "Password is Required Field"), MinLengthRule(length: 6, message: "Password is aleast 6 digit")])
    }
    
    func setUpLayerDesign() {
        let textFieldArray = [emailTextField, passwordTextField]
        for i in 0...textFieldArray.count - 1 {
            textFieldArray[i]?.layer.borderWidth = 0.6
            textFieldArray[i]?.layer.cornerRadius = 5
        }
    }
    
    
    @IBAction func login(_ sender: UIButton) {
        buttonClick = true
        validator.validate(self)
        let validationStatus = UserDefaults.standard.integer(forKey: "validateStatus")
        if validationStatus == 1 {
            SVProgressHUD.show()
            self.callLoginAPI(email: emailTextField.text!, password: passwordTextField.text!)
        }
    }
    
    func callLoginAPI(email : String, password : String) {
        if Connectivity.isConnectedToInternet {
            SVProgressHUD.show()
            let parameters = [
                "email" : email,
                "password" : password
            ]
            Service.shared.login(parameter: parameters, completion: { (response)-> Void in
                SVProgressHUD.dismiss()
                let result = response
                if result.status == "success"{
                    UserDefaults.standard.set(result.type, forKey: "userType")
                    UserDefaults.standard.set(result.token, forKey: "token")
                    UserDefaults.standard.set(result.name, forKey: "name")
                    UserDefaults.standard.set(result.profile, forKey: "profile")
                    self.goToPostList()
                }else if result.status == "fail"{
                    AlertHelper.present(in: self, title: "Error", message: result.message ?? "Error Message", actionTitle: "OK", handler: nil)
                }else {
                    AlertHelper.present(in: self, title: "Error", message: result.error ?? "Error Message", actionTitle: "OK", handler: nil)
                }
            })
            
        }else {
            DispatchQueue.main.async {
                self.view.makeToast(Constants.networkError, duration: 3.0, position: .bottom)
            }
        }
    }
    
    func goToPostList() {
        let vc = ContainerVC()
        DispatchQueue.main.async {
            self.navigationController?.isNavigationBarHidden = true
        }
        self.navigationController?.pushViewController(vc, animated: true)
        self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    @IBAction func textFieldChanged(_ sender: Any) {
        if buttonClick {
            validator.validate(self)
        }
    }
    
    @IBAction func iconAction(_ sender: Any) {
        if iconClick == true {
            passwordTextField.isSecureTextEntry = false
            visibleIcon.setImage(UIImage.init(systemName: "eye.slash"), for: .normal)
        }else{
            passwordTextField.isSecureTextEntry = true
            visibleIcon.setImage(UIImage.init(systemName: "eye.slash.fill"), for: .normal)
        }
        iconClick = !iconClick
    }
    
    func checkToken() {
        let token = UserDefaults.standard.string(forKey: "token")
        Service.shared.checkToken(token: token ?? "", completion: { (response) -> Void in
            let result = response
            if result.status != "success"{
                Service.shared.logout(token: token ?? "", completion: { (logoutResponse) -> Void in
                    let result = logoutResponse
                    if result.status == "success"{
                        let domain = Bundle.main.bundleIdentifier!
                        UserDefaults.standard.removePersistentDomain(forName: domain)
                        UserDefaults.standard.synchronize()
                        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                        self.navigationController?.pushViewController(vc!, animated: true)
                    }
                })
            }else{
                self.goToPostList()
            }
        })
    }
}
