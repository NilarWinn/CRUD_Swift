//
//  CreateUserVC.swift
//  MVC-Swift
//
//  Created by NilarWin on 17/08/2022.
//

import UIKit
import SwiftValidator
import DropDown

class CreateUserVC : UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameError: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailError: UILabel!
    @IBOutlet weak var passwordError: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordError: UILabel!
    @IBOutlet weak var userTypeTextField: UITextField!
    @IBOutlet weak var phoneError: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var userTypeSelectView: UIView!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var confirmPasswordIcon: UIButton!
    @IBOutlet weak var passwordIcon: UIButton!
    @IBOutlet weak var profileEditButton: UIButton!
    @IBOutlet weak var chooseImageView: UIView!
    @IBOutlet weak var profieHeight: NSLayoutConstraint!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var confirmPasswordView: UIView!
    @IBOutlet weak var profileHeightCreate: NSLayoutConstraint!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var navTitle: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    let validator = Validator()
    var buttonClick = false
    var userTypeArr = ["User", "Admin"]
    let dropDown = DropDown()
    let label = UILabel(frame: CGRect(x: 10, y: 2, width: 200, height: 30))
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.datePickerMode = .date
        datePicker.timeZone = TimeZone.current
        return datePicker
    }()
    var imageData = ""
    var chooseImage: UIImage? = nil
    var editUser = false
    var CreateUserVC = false
    var isProfile = false
    var selectedUser: User? = nil
    var fileName = ""
    var uploadFileURL = ""
    var uploadFileName = ""
    var uploadFileMimeType = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navTitle.text = editUser ? "Edit User" : "Create User"
        setUpLayerDesign()
        setValidation()
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.showUserTypeDropDown))
        userTypeSelectView.addGestureRecognizer(gesture)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard)))
        setDatePicker()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        if(editUser){
            setUserData()
        }
    }
    
    func setUserData() {
        nameTextField.text = selectedUser?.name
        emailTextField.text = selectedUser?.email
        phoneTextField.text = selectedUser?.phone
        let dob = selectedUser?.dob
        if dob?.count ?? 0 > 0 {
            dobTextField.text = dob!.count > 0 ?  formattedDateFromString(dateString: String(dob!.split(separator: "T")[0]), withFormat: "dd-MM-yyyy") : ""
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            let selectedDate = formatter.date(from: dobTextField.text!)
            datePicker.date = selectedDate!
        }
        addressTextView.text = selectedUser?.address
        userTypeTextField.text = selectedUser?.type == "1" ? "User" : "Admin"
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height , right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @IBAction func chooseUserType(_ sender: Any) {
        showUserTypeDropDown()
    }
    
    @objc func showUserTypeDropDown() {
        if editUser == false {
            dropDown.anchorView = userTypeSelectView
            dropDown.dataSource =  userTypeArr
            dropDown.dismissMode = .onTap
            dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
                userTypeTextField.text = userTypeArr[index]
            }
            dropDown.direction = .bottom
            dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
            dropDown.topOffset = CGPoint(x: 0, y:-(dropDown.anchorView?.plainView.bounds.height)!)
            dropDown.width = userTypeSelectView.frame.width
            dropDown.selectedTextColor = #colorLiteral(red: 0.3450980392, green: 0.6, blue: 0.8196078431, alpha: 1)
            dropDown.selectionBackgroundColor = UIColor.white
            for (index,status) in userTypeArr.enumerated() {
                if status == userTypeTextField.text {
                    dropDown.selectRow(index)
                }
            }
            dropDown.show()
        }
    }
    
    func setUpLayerDesign(){
        let textFieldArray = [nameTextField, emailTextField, passwordTextField, confirmPasswordTextField, userTypeTextField, phoneTextField, dobTextField, addressTextView,profileButton ,profileEditButton]
        for i in 0...textFieldArray.count - 1 {
            textFieldArray[i]?.layer.borderWidth = 0.6
            textFieldArray[i]?.layer.cornerRadius = 5
        }
        confirmButton.layer.cornerRadius = 5
        clearButton.layer.cornerRadius = 5
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        checkEditLayout()
    }
    
    func checkEditLayout(){
        profileHeightCreate.constant = editUser == true ? 0.0 : 95.0
        profieHeight.constant = editUser == true ? 150.0 : 0.0
        profileEditButton.isHidden = !editUser
        profileButton.frame.size.height = editUser == true ? 0.0 : 35.0
        profileButton.isHidden = editUser
        changePasswordButton.isHidden = !isProfile
        profile.isHidden = !editUser
        changePasswordButton.frame.size.height = isProfile == true ? 30.0 : 0.0
        if editUser {
            self.confirmPasswordView.constrainHeight(constant: 0)
            self.passwordView.constrainHeight(constant: 0)
            passwordTextField.isHidden = true
            confirmPasswordTextField.isHidden = true
        }
    }
    
    func setValidation() {
        emailTextField.delegate = self
        if editUser == false {
            validator.registerField(passwordTextField, errorLabel: passwordError, rules: [RequiredRule(message: "Password is Required Field"), MinLengthRule(length: 8, message: "Password is aleast 8 digit")])
            validator.registerField(confirmPasswordTextField, errorLabel: confirmPasswordError, rules: [RequiredRule(message: "Confirm Password is Required Field"), MinLengthRule(length: 8, message: "Confirm Password is aleast 8 digit")])
        }
        validator.registerField(nameTextField, errorLabel: nameError, rules: [RequiredRule(message: "Name is Required Field")])
        validator.registerField(emailTextField, errorLabel: emailError, rules: [RequiredRule(message: "Email is Required Field"), EmailRule(message: "Invalid email")])
        validator.registerField(phoneTextField, errorLabel: phoneError, rules: [RequiredRule(message: "Phone is Required Field"), MinLengthRule(length: 10, message: "Invalid Phone Number")])
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
    
    func setDatePicker(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        dobTextField.inputAccessoryView = toolbar
        dobTextField.inputView = datePicker
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
    }
    
    @objc func handleDatePicker() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dobTextField.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    @IBAction func textFieldChanged(_ sender: Any) {
        if buttonClick {
            validator.validate(self)
        }
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        let myPickerController = UIImagePickerController()
        myPickerController.allowsEditing = true
        myPickerController.delegate = self
        myPickerController.sourceType =  UIImagePickerController.SourceType.photoLibrary
        self.present(myPickerController, animated: true, completion: nil)
    }
    
    @IBAction func confirm(_ sender: Any) {
        buttonClick = true
        validator.validate(self)
        if passwordTextField.text != confirmPasswordTextField.text {
            UserDefaults.standard.set(0, forKey: "validateStatus")
            confirmPasswordError.isHidden = false
            confirmPasswordError.text = "Not same data with password"
            return
        }
        let validationStatus = UserDefaults.standard.integer(forKey: "validateStatus")
        
        if validationStatus == 1{
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CreateUserConfirmVC") as? CreateUserConfirmVC
            let user = User(_id: selectedUser?._id, name: self.nameTextField.text, email: self.emailTextField.text, password: self.passwordTextField.text, profile: self.imageData, type: self.userTypeTextField.text, phone: self.phoneTextField.text, address: self.addressTextView.text, dob: self.dobTextField.text, create_user_id: 1)
            vc?.userData = user
            vc?.image = chooseImage == nil ? nil : chooseImage
            vc?.editUser = editUser
            vc?.isProfile = isProfile
            vc?.fileName = fileName
            vc?.uploadFileURL = uploadFileURL
            vc?.uploadFileName = uploadFileName
            vc?.uploadFileMimeType = uploadFileMimeType
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    @IBAction func clear(_ sender: Any) {
        let textFieldArray : [UITextField] = [nameTextField, emailTextField, passwordTextField, confirmPasswordTextField, userTypeTextField, phoneTextField, dobTextField ]
        for i in 0...textFieldArray.count - 1 {
            textFieldArray[i].text = ""
        }
        addressTextView.text = ""
        if  chooseImage != nil {
            chooseImage = nil
            label.text = "Choose Image"
            profileButton.addSubview(label)
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imgUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL{
            let imgName = imgUrl.lastPathComponent
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            let localPath = documentDirectory?.appending(imgName)
            
            let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            let data = image.pngData()! as NSData
            data.write(toFile: localPath!, atomically: true)
            let photoURL = URL.init(fileURLWithPath: localPath!)
            uploadFileURL = String("\(photoURL)")
            let filename = photoURL.lastPathComponent
            fileName = filename
            self.uploadFileName = "attachFile.\(photoURL.pathExtension)"
            self.uploadFileMimeType = mimeType(for: self.uploadFileURL)
            chooseImage = image
            profile.image = chooseImage
            label.textAlignment = .left
            label.text = filename
            label.lineBreakMode = .byTruncatingTail
            label.numberOfLines = 0
            if editUser == true {
                profileEditButton.setTitle("", for: .normal)
                profileEditButton.addSubview(label)
            }else{
                profileButton.setTitle("", for: .normal)
                profileButton.addSubview(label)
            }
        }
        dismiss(animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @IBAction func confirmPasswordIconAction(_ sender: Any) {
        visibleIconCheck(textfield: confirmPasswordTextField, icon: confirmPasswordIcon)
    }
    
    @IBAction func passwordIconAction(_ sender: Any) {
        visibleIconCheck(textfield: passwordTextField, icon: passwordIcon)
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
    
    @IBAction func changePasswordAction(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ChangePasswordVC") as? ChangePasswordVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
}
