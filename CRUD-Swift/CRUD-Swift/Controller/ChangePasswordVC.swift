//
//  ChangePasswordVC.swift
//  MVC-Swift
//
//  Created by NilarWin on 22/08/2022.
//

import Foundation
import UIKit
import SwiftValidator
import SVProgressHUD
import Alamofire
import SwiftyJSON

class ChangePasswordVC: UIViewController {
    
    @IBOutlet weak var confirmPasswordError: UILabel!
    @IBOutlet weak var newPasswordError: UILabel!
    @IBOutlet weak var oldPasswordError: UILabel!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordIcon: UIButton!
    @IBOutlet weak var newPasswordIcon: UIButton!
    @IBOutlet weak var oldPasswordIcon: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    let validator = Validator()
    var buttonClick = false
    var token = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLayerDesign()
        setValidation()
        token = UserDefaults.standard.string(forKey: "token")!
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard)))
    }
    
    func setUpLayerDesign() {
        let textFieldArray = [oldPasswordTextField, newPasswordTextField, confirmPasswordTextField]
        for i in 0...textFieldArray.count - 1 {
            textFieldArray[i]?.layer.borderWidth = 0.6
            textFieldArray[i]?.layer.cornerRadius = 5
        }
        confirmButton.layer.cornerRadius = 5
        clearButton.layer.cornerRadius = 5
        oldPasswordTextField.isSecureTextEntry = true
        newPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
    }
    
    func setValidation() {
        validator.registerField(oldPasswordTextField, errorLabel: oldPasswordError, rules: [RequiredRule(message: "Old Password is Required Field"), MinLengthRule(length: 8, message: "Password is aleast 8 digit")])
        validator.registerField(newPasswordTextField, errorLabel: newPasswordError, rules: [RequiredRule(message: "New Password is Required Field"), MinLengthRule(length: 8, message: "New Password is aleast 8 digit")])
        validator.registerField(confirmPasswordTextField, errorLabel: confirmPasswordError, rules: [RequiredRule(message: "Confirm Password is Required Field"), MinLengthRule(length: 8, message: "Confirm Password is aleast 8 digit")])
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
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clear(_ sender: Any) {
        oldPasswordTextField.text = ""
        newPasswordTextField.text = ""
        confirmPasswordTextField.text = ""
    }
    
    @IBAction func confirm(_ sender: Any) {
        buttonClick = true
        validator.validate(self)
        if newPasswordTextField.text != confirmPasswordTextField.text {
            UserDefaults.standard.set(0, forKey: "validateStatus")
            confirmPasswordError.isHidden = false
            confirmPasswordError.text = "Not same data with password"
            return
        }
        let validationStatus = UserDefaults.standard.integer(forKey: "validateStatus")
        if validationStatus == 1{
            if Connectivity.isConnectedToInternet {
                SVProgressHUD.show()
                let parameter = [
                    "old_password" : oldPasswordTextField.text,
                    "new_password" : newPasswordTextField.text
                ]
                Service.shared.changePassword(token: token, parameter: parameter as Parameters) { (response)-> Void in
                    let result = response
                    SVProgressHUD.dismiss()
                    if result.status == "success"{
                        self.view.makeToast(result.message, duration: 3.0, position: .bottom)
                        self.navigationController?.popViewController(animated: true)
                    }else {
                        AlertHelper.present(in: self, title: "Error", message: result.message ?? "Error Message", actionTitle: "OK", handler: {
                            if(result.message == "Unauthorized") {
                                self.logout()
                            }
                        })
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.view.makeToast(Constants.networkError, duration: 3.0, position: .bottom)
                }
            }
        }
    }
    
    @IBAction func EditIcon(_ sender: UIButton) {
        if sender == oldPasswordIcon {
            visibleIconCheck(textfield: oldPasswordTextField, icon: oldPasswordIcon)
        }else if sender == newPasswordIcon {
            visibleIconCheck(textfield: newPasswordTextField, icon: newPasswordIcon)
        }else if sender == confirmPasswordIcon {
            visibleIconCheck(textfield: confirmPasswordTextField, icon: confirmPasswordIcon)
        }
    }
    
    func visibleIconCheck(textfield: UITextField, icon: UIButton){
        if textfield.isSecureTextEntry == true {
            textfield.isSecureTextEntry = false
            icon.setImage(UIImage.init(systemName: "eye.slash"), for: .normal)
        }else{
            textfield.isSecureTextEntry = true
            icon.setImage(UIImage.init(systemName: "eye.slash.fill"), for: .normal)
        }
    }
    
    @IBAction func textFieldChanged(_ UITextField: Any) {
        if buttonClick {
            validator.validate(self)
        }
    }
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
}
