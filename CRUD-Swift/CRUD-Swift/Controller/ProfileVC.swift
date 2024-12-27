//
//  ProfileVC.swift
//  MVC-Swift
//
//  Created by NilarWin on 19/08/2022.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

class ProfileVC: UIViewController {
    
    @IBOutlet weak var profileScrollView: UIScrollView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var userTypeLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressStackView: UIStackView!
    var profileData:User? = nil
    var token = UserDefaults.standard.string(forKey: "token") ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Connectivity.isConnectedToInternet {
            SVProgressHUD.show()
            getProfile()
        } else {
            DispatchQueue.main.async {
                self.view.makeToast(Constants.networkError, duration: 3.0, position: .bottom)
            }
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editAction(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CreateUserVC") as? CreateUserVC
        vc?.editUser = true
        vc?.isProfile = true
        vc?.selectedUser = self.profileData
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func getProfile() {
        Service.shared.profile(token: token, completion: { (response)-> Void in
            let result = response
            SVProgressHUD.dismiss()
            if result.status == "success"{
                let userData = result.data!
                self.profileData = userData
                self.nameLabel.text = userData.name
                self.emailLabel.text = userData.email
                self.userTypeLabel.text = userData.type == "0" ? "Admin" : "User"
                self.phoneLabel.text = userData.phone
                self.addressLabel.text = userData.address
                let dob:String = userData.dob ?? ""
                self.dobLabel.text = dob.count > 0 ?  formattedDateFromString(dateString: String(dob.split(separator: "T")[0]), withFormat: "dd-MM-yyyy") : ""
            }else{
                AlertHelper.present(in: self, title: "Error", message: result.message ?? "Error Message", actionTitle: "OK", handler: {
                    if(result.message == "Unauthorized") {
                        self.logout()
                    }
                })
            }
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded()
        profileScrollView.contentSize.height  = addressStackView.frame.origin.y + addressStackView.frame.size.height + 20
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        profileData = nil
    }
}
