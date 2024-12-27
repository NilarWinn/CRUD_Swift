//
//  ViewController.swift
//  Sidebar Menu
//
//  Created by Sushil Rathaur on 09/06/20.
//  Copyright © 2020 AppCodeZip. All rights reserved.
//

import UIKit

class HomeVC: UIViewController, MenuDelegate {
    
    var delegate: MenuDelegate?
    var centerVC :UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "PostListVC") as? PostListVC
        vc?.delegate = self
        centerVC = UINavigationController(rootViewController: vc!)
        self.view.addSubview(centerVC.view)
    }
    
    func menuHandler(index: Int) {
        delegate?.menuHandler(index: -1)
    }
    
    func goToPostEdit(data: Post) {
        delegate?.goToPostEdit(data: data)
    }
}
