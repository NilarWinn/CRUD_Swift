//
//  UploadCsvVC.swift
//  MVC-Swift
//
//  Created by NilarWin on 15/08/2022.
//

import Foundation
import UIKit
import UniformTypeIdentifiers
import MobileCoreServices
import SwiftValidator
import Alamofire
import SwiftyJSON
import Toast_Swift

struct DecodableType: Decodable {
    let url: String
}

class UploadCsvVC: UIViewController, UIDocumentPickerDelegate {
    
    @IBOutlet weak var uploadView: UIView!
    @IBOutlet weak var uploadError: UILabel!
    @IBOutlet weak var uploadTextField: UITextField!
    @IBOutlet weak var importButton: UIButton!
    
    let validator = Validator()
    var buttonClick = false
    var filePath : String?
    var data = Data()
    var uploadFileURL = ""
    var uploadFileName = ""
    var uploadFileMimeType = ""
    var fileURL : URL? = URL(string: "www.apple.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.uploadView.layer.cornerRadius = 5
        self.uploadView.layer.borderWidth = 0.6
        self.uploadView.layer.borderColor = UIColor.black.cgColor
        validator.registerField(uploadTextField, errorLabel: uploadError, rules: [RequiredRule(message: "Import File is Required Field")])
        validator.styleTransformers(success: { (validationRule) -> Void in
            validationRule.errorLabel?.isHidden = true
            validationRule.errorLabel?.text = ""
            self.uploadView.layer.borderColor = UIColor.black.cgColor
            
        }, error: {(validationError) -> Void in
            validationError.errorLabel?.isHidden = false
            validationError.errorLabel?.text = validationError.errorMessage
            self.uploadView.layer.borderColor = UIColor.red.cgColor
        })
        importButton.layer.cornerRadius = 5
    }
    
    @IBAction func textFieldDidChanged(_ sender: Any) {
        if buttonClick {
            validator.validate(self)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func importField(_ sender: Any) {
        buttonClick = true
        validator.validate(self)
        let validationStatus = UserDefaults.standard.integer(forKey: "validateStatus")
        
        if validationStatus == 1{
            callUploadApi()
        }else{
            AlertHelper.present(in: self, title: "Error", message: Constants.invalidError, actionTitle: "OK", handler: nil)
        }
    }
    
    func callUploadApi() {
        let token = UserDefaults.standard.string(forKey: "token") ?? ""
        if uploadFileURL != "" {
            let fileurl = NSURL(string: self.uploadFileURL)
            data = try! Data(contentsOf: fileurl! as URL)
        }
        if Connectivity.isConnectedToInternet {
            Service.shared.uploadCSV(token: token, uploadFileName: uploadFileName, uploadFileMimeType: uploadFileMimeType, data: data) { (response)-> Void in
                let result = response
                if result.status == "success"{
                    self.navigationController?.popViewController(animated: true)
                    self.view.makeToast(result.message, duration: 3.0, position: .bottom)
                }else if result.status == "error"{
                    AlertHelper.present(in: self, title: "Error", message: result.message ?? "Error Message", actionTitle: "OK", handler: {
                        if(result.message == "Unauthorized") {
                            self.logout()
                        }
                    })
                }
            }
        }else{
            DispatchQueue.main.async {
                self.view.makeToast(Constants.networkError, duration: 3.0, position: .bottom)
            }
        }
    }
    
    @IBAction func uploadFileAction(_ sender: Any) {
        let supportedTypes: [UTType] = [UTType.item]
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.shouldShowFileExtensions = true
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        self.uploadTextField.text = myURL.lastPathComponent
        self.uploadFileURL = String("\(myURL)")
        self.fileURL = myURL
        self.uploadFileName = "attachFile.\(myURL.pathExtension)"
        self.uploadFileMimeType = mimeType(for: self.uploadFileURL)
    }
    
    public func documentMenu(_ documentMenu:UIDocumentPickerViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
