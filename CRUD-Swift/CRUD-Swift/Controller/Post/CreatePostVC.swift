//
//  CreatePostVC.swift
//  MVC-Swift
//
//  Created by NilarWin on 11/08/2022.
//

import UIKit
import SwiftValidator

class CreatePostVC: UIViewController, UITextViewDelegate {
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var titleError: UILabel!
    @IBOutlet weak var descriptionError: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var swtichView: UIStackView!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var navTitle: UILabel!
    var statusValue : Bool = true
    var editClick: Bool?
    let validator = Validator()
    var confirmClick = false
    var selectedPost : Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navTitle.text = editClick! ? "Edit Post" : "Create Post"
        descriptionTextView.delegate = self
        self.navigationController?.isNavigationBarHidden = true
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard)))
        setUpLayerDesign()
        validator.registerField(titleTextField, errorLabel: titleError, rules: [RequiredRule(), MaxLengthRule(length: 255, message: "Maximum length is 255")])
        validator.registerField(descriptionTextView, errorLabel: descriptionError, rules: [RequiredRule()])
        validator.styleTransformers(success: { (validationRule) -> Void in
            validationRule.errorLabel?.isHidden = true
            validationRule.errorLabel?.text = ""
            if let textfield = validationRule.field as? UITextField {
                textfield.layer.borderColor = UIColor.black.cgColor
            }else {
                let textView = validationRule.field as? UITextView
                textView?.layer.borderColor = UIColor.black.cgColor
            }
        }, error: {(validationError) -> Void in
            validationError.errorLabel?.isHidden = false
            validationError.errorLabel?.text = validationError.errorMessage
            if let textfield = validationError.field as? UITextField {
                textfield.layer.borderColor = UIColor.red.cgColor
            }else {
                let textView = validationError.field as? UITextView
                textView?.layer.borderColor = UIColor.red.cgColor
            }
        })
        
        if editClick!{
            let selectedStatus : Int = Int((selectedPost?.status)!)!
            titleTextField.text = selectedPost?.title
            descriptionTextView.text = selectedPost?.description
            statusValue = selectedStatus == 0 ? false : true
        }
        switchButton.isOn = statusValue
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if confirmClick{
            validator.validate(self)
        }
    }
    
    @IBAction func backActionClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func confirm(_ sender: Any) {
        confirmClick = true
        validator.validate(self)
        let validationStatus = UserDefaults.standard.integer(forKey: "validateStatus")
        if validationStatus == 1 {
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CreatePostConfirmVC") as? CreatePostConfirmVC
            vc?.selectedPost = Post(id: self.selectedPost?.id, title: self.titleTextField.text, description: self.descriptionTextView.text, status: statusValue == false ? "0" : "1", posted_by: CreatedBy(name: "", type: ""))
            vc?.editClick = self.editClick
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    func setUpLayerDesign(){
        let textFieldArray = [titleTextField, descriptionTextView]
        for i in 0...textFieldArray.count - 1 {
            textFieldArray[i]?.layer.borderWidth = 0.6
            textFieldArray[i]?.layer.cornerRadius = 5
        }
        confirmButton.layer.cornerRadius = 5
        clearButton.layer.cornerRadius = 5
        if editClick == false {
            hideStatusView()
        }
    }
    
    func hideStatusView() {
        statusLabel.isHidden = true
        switchButton.isHidden = true
        switchButton.frame.size.height = 0
        swtichView.layoutIfNeeded()
    }
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    @IBAction func switchAction(_ sender: Any) {
        statusValue = !statusValue
    }
    
    @IBAction func textFieldChanged(_ sender: Any) {
        if confirmClick {
            validator.validate(self)
        }
    }
    
    @IBAction func clear(_ sender: Any) {
        descriptionTextView.text = ""
        titleTextField.text = ""
    }
}
