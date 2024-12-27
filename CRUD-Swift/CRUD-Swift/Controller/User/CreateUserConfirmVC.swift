//
//  CreateUserConfirmVC.swift
//  MVC-Swift
//
//  Created by NilarWin on 17/08/2022.
//

import UIKit
import SVProgressHUD
import Alamofire
import SwiftyJSON

class CreateUserConfirmVC: UIViewController{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var userTypeLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var passwordView: UIStackView!
    @IBOutlet weak var userConfirmScrollView: UIScrollView!
    @IBOutlet weak var userConfirmView: UIView!
    @IBOutlet weak var userConfirmDataView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var navTitle: UILabel!
    var image: UIImage?
    var editUser = true
    var userData: User?
    var viewHeight: Float = 0.0
    var token = ""
    var isProfile = false
    var uploadFileURL = ""
    var uploadFileName = ""
    var uploadFileMimeType = ""
    var data = Data()
    var formatDOB = ""
    var fileName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        token = UserDefaults.standard.string(forKey: "token")!
        navTitle.text = editUser ? "Edit User Confirmation" : "Create User Confirmation"
        nameLabel.text = userData?.name
        emailLabel.text = userData?.email
        if editUser == false {
            var star = ""
            let strLength : String = (userData?.password)!
            for _ in 1...strLength.count {
                star += "*"
            }
            passwordLabel.text = star
        }else {
            passwordView.constrainHeight(constant: 0)
        }
        userTypeLabel.text = userData?.type
        phoneLabel.text = userData?.phone
        dobLabel.text = userData?.dob
        addressLabel.text = userData?.address
        if image != nil {
            profile.image = image
        }
        nameLabel.sizeToFit()
        emailLabel.sizeToFit()
        addressLabel.sizeToFit()
        updateButton.layer.cornerRadius = 5
        cancelButton.layer.cornerRadius = 5
        updateButton.titleLabel?.text = editUser == true ? "Update" : "Create"
        if userData?.dob?.count ?? 0 > 0 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT+00:00")//Add this
            let date = dateFormatter.date(from: (userData?.dob!)!)
            formatDOB = date!.getFormattedDate(format: "yyyy-MM-dd")
        }else {
            formatDOB = ""
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func updateAction(_ sender: Any) {
        if Connectivity.isConnectedToInternet {
            SVProgressHUD.show()
            var url = ""
            var parameter: Parameters = [
                "name" : userData?.name as Any,
                "email" : userData?.email as Any,
                "password" : userData?.password as Any,
                "profile" : image as Any,
                "type" : userData?.type == "Admin" ? "0" : "1" as Any,
                "phone" : userData?.phone as Any,
                "address" : userData?.address as Any,
                "dob" : formatDOB as Any,
                "id" : userData?._id as Any,
            ]
            
            if isProfile {
                url = "\(Network.HOSTAPI)user/profile"
                parameter.removeValue(forKey: "id")
            }else if editUser {
                url = "\(Network.HOSTAPI)user/update"
            }else {
                url = "\(Network.HOSTAPI)user/create"
                parameter.removeValue(forKey: "id")
            }
            
            Service.shared.createUser(url: url, token: token, parameter: parameter, uploadFileURL: uploadFileURL, fileName: fileName, uploadFileMimeType: uploadFileMimeType, image: image, completion: {(response) -> Void in
                let result = response
                SVProgressHUD.dismiss()
                if result.status == "success"{
                    if self.isProfile == true {
                        let responseData = result.data
                        UserDefaults.standard.set(responseData?.name, forKey: "name")
                        if self.uploadFileURL.count > 0 {
                            UserDefaults.standard.set(responseData?.profile, forKey: "profile")
                        }
                        let vc = ContainerVC()
                        self.navigationController?.pushViewController(vc, animated: true)
                        self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
                    }else{
                        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "UserListVC") as? UserListVC
                        self.navigationController?.pushViewController(vc!, animated: true)
                    }
                    
                    self.view.makeToast(result.message, duration: 3.0, position: .bottom)
                }else if result.status == "error"{
                    AlertHelper.present(in: self, title: "Error", message: result.message ?? "Eroor Message", actionTitle: "OK", handler: {
                        if(result.message == "Unauthorized") {
                            self.logout()
                        }
                    })
                }
            })
        } else {
            DispatchQueue.main.async {
                self.view.makeToast(Constants.networkError, duration: 3.0, position: .bottom)
            }
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let dataHeight: Float = Float(nameLabel.frame.size.height + emailLabel.frame.size.height + addressLabel.frame.size.height + 500.0)
        userConfirmView.frame.size.height = 0.0
        userConfirmScrollView.contentSize.height = CGFloat(dataHeight)
        userConfirmView.heightAnchor.constraint(equalToConstant: CGFloat(dataHeight)).isActive = true
    }
    
}
extension Date {
    func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}
