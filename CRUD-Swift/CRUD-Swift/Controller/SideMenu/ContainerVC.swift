//
//  ContainerViewController.swift
//  Sidebar Menu
//
//  Created by Sushil Rathaur on 09/06/20.
//  Copyright © 2020 AppCodeZip. All rights reserved.
//

import UIKit
import SafariServices
import Alamofire
import SwiftyJSON

class ContainerVC: UIViewController {
    
    var menuController : MenuVC!
    var centerVC :UIViewController!
    var homeVC :HomeVC!
    var isExpandMenu : Bool = false
    var userType = UserDefaults.standard.integer(forKey: "userType")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHomeFun()
    }
    
    override var prefersStatusBarHidden: Bool{
        return isExpandMenu
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return .slide
    }
    
    func configureStatusbarAnimation(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    
    func setHomeFun(){
        if homeVC == nil {
            homeVC = HomeVC()
            homeVC.delegate = self
            centerVC = UINavigationController(rootViewController: homeVC)
            self.view.addSubview(centerVC.view)
            addChild(centerVC)
            centerVC.didMove(toParent: self)
        }
    }
    
    func setHomeFun(index:Int){
        configureMenu()
        if index == 1 {
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if index == 2 {
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CreatePostVC") as? CreatePostVC
            vc?.editClick = false
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else  if index == 3 {
            let vc = ContainerVC()
            self.navigationController?.pushViewController(vc, animated: true)
            self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
        }
        else  if index == 4 {
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MyPostListVC") as? MyPostListVC
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else  if index == 5 {
            if userType == 0 {
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CreateUserVC") as? CreateUserVC
                vc?.editUser = false
                self.navigationController?.pushViewController(vc!, animated: true)
            }else{
                logoutAlert()
            }
        }
        else if index == 6{
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "UserListVC") as? UserListVC
            self.navigationController?.pushViewController(vc!, animated: true)
        }else if index == 7{
            logoutAlert()
        }
    }
    
    @objc func configureMenu()  {
        if menuController == nil {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            menuController = storyBoard.instantiateViewController(identifier: "MenuVC") as? MenuVC
            menuController.delegate = self
            view.insertSubview(menuController.view , at: 0)
            addChild(menuController)
            menuController.didMove(toParent: self)
        }
    }
    
    func logoutAlert() {
        let alertController = UIAlertController(title: "Confirm", message: "Are you want to sure Exit?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.logout()
        }
        alertController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in
            alertController.dismiss(animated: true)
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showMenu(isExpand:Bool){
        if isExpand {
            //open Menu
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.centerVC.view.frame.origin.x = self.centerVC.view.frame.width - 100
                self.centerVC.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ContainerVC.menuHandler)))
            }, completion: nil)
        }else{
            //close Menu
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.centerVC.view.frame.origin.x = 0
                if let recognizers = self.centerVC.view.gestureRecognizers {
                    for recognizer in recognizers {
                        self.centerVC.view.removeGestureRecognizer(recognizer)
                    }
                }
            }, completion: nil)
        }
        configureStatusbarAnimation()
    }
    
    func postEdit(data: Post) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CreatePostVC") as? CreatePostVC
        vc?.editClick = true
        vc?.selectedPost = data
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @objc func removeGesture() {
        
    }
}
extension ContainerVC : MenuDelegate{
    
    @objc func menuHandler(index: Int) {
        if !isExpandMenu {
            configureMenu()
        }
        isExpandMenu = !isExpandMenu
        showMenu(isExpand: isExpandMenu)
        if index > -1 {
            setHomeFun(index: index)
        }
    }
    
    func goToPostEdit(data: Post) {
        postEdit(data: data)
    }
}
protocol MenuDelegate {
    func menuHandler(index : Int)
    func goToPostEdit(data: Post)
}
