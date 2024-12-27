//
//  CreatePostConfirmVC.swift
//  MVC-Swift
//
//  Created by NilarWin on 11/08/2022.
//

import UIKit
import SVProgressHUD
import Alamofire
import SwiftyJSON

class CreatePostConfirmVC: UIViewController {
    
    @IBOutlet weak var navTitle: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var confirmSwitchButton: UISwitch!
    @IBOutlet weak var confirmSwitchLabel: UILabel!
    @IBOutlet weak var confirmSwitchView: UIStackView!
    @IBOutlet weak var postConfirmView: UIView!
    @IBOutlet weak var postConfirmScrollView: UIScrollView!
    var postStatus: Int?
    var editClick: Bool?
    var token = UserDefaults.standard.string(forKey: "token") ?? ""
    var selectedPost : Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navTitle.text = editClick! ? "Edit Post Confirmation" : "Create Post Confirmation"
        updateButton.layer.cornerRadius = 5
        cancelButton.layer.cornerRadius = 5
        titleLabel.text = selectedPost?.title
        descriptionLabel.text = selectedPost?.description
        postStatus = Int((selectedPost?.status)!)
        
        if editClick == false {
            confirmSwitchLabel.isHidden = true
            confirmSwitchButton.isHidden = true
            confirmSwitchButton.frame.size.height = 0
            confirmSwitchView.layoutIfNeeded()
        }
        switchButton.isOn = selectedPost?.status == "0" ? false : true
        switchButton.isEnabled = false
        updateButton.titleLabel?.text = editClick == true ? "Update" : "Create"
        titleLabel.sizeToFit()
        descriptionLabel.sizeToFit()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func update(_ sender: Any) {
        if Connectivity.isConnectedToInternet {
            SVProgressHUD.show()
            if editClick! {
                let parameter = [
                    "post_id": selectedPost?.id ?? "",
                    "title": titleLabel.text ?? "",
                    "description": descriptionLabel.text ?? "",
                    "status" : postStatus ?? ""
                ] as [String : Any]
                Service.shared.updatePost(token: token, parameter: parameter as Parameters, completion: { (response) -> Void in
                    let result = response
                    SVProgressHUD.dismiss()
                    if result.status == "success"{
                        self.navigationController?.pushViewController(ContainerVC(), animated: true)
                        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                        self.view.makeToast(result.message, duration: 3.0, position: .bottom)
                    }else{
                        AlertHelper.present(in: self, title: "Error", message: result.message ?? "Error Message", actionTitle: "OK", handler: {
                            if(result.message == "Unauthorized") {
                                self.logout()
                            }
                        })
                    }
                })
            } else {
                let parameter = [
                    "title": titleLabel.text,
                    "description": descriptionLabel.text
                ]
                Service.shared.createPost(token: token, parameter: parameter as Parameters, completion: { (response) -> Void in
                    let result = response
                    SVProgressHUD.dismiss()
                    if result.status == "success"{
                        self.navigationController?.pushViewController(ContainerVC(), animated: true)
                        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                        self.view.makeToast(result.message, duration: 3.0, position: .bottom)
                    }else{
                        AlertHelper.present(in: self, title: "Error", message: result.message ?? "Error Message", actionTitle: "OK", handler: {
                            if(result.message == "Unauthorized") {
                                self.logout()
                            }
                        })
                    }
                })
            }
        } else {
            DispatchQueue.main.async {
                self.view.makeToast(Constants.networkError, duration: 3.0, position: .bottom)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let viewHeight: Float = Float(titleLabel.frame.size.height + descriptionLabel.frame.size.height + 170.0)
        postConfirmScrollView.contentSize.height  = CGFloat(viewHeight)
    }
}
