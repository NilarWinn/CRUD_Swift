//
//  MenuVC.swift
//  MVC-Swift
//
//  Created by NilarWin on 12/08/2022.
//

import UIKit

class MenuVC: UIViewController {
    var imageHeaderView: HeaderView!
    var delegate : MenuDelegate?
    
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    var menusClient : Array = [["txtMenu":"Profile", "imgMenu":"about"],["txtMenu":"Add New Post", "imgMenu":"about"],["txtMenu":"Post List", "imgMenu":"about"],["txtMenu":"My Post List", "imgMenu":"about"],["txtMenu":"Logout", "imgMenu":"rectangle.portrait.and.arrow.right.fill"]]
    
    var menusClientAdmin : Array = [["txtMenu":"Profile", "imgMenu":"person.circle.fill"],["txtMenu":"Add New Post", "imgMenu":"plus.circle.fill"],["txtMenu":"Post List", "imgMenu":"list.bullet"],["txtMenu":"My Post List", "imgMenu":"list.bullet"],["txtMenu":"Add New User", "imgMenu":"person.crop.circle.fill.badge.plus"],["txtMenu":"User List", "imgMenu":"person.3.fill"],["txtMenu":"Logout", "imgMenu":"rectangle.portrait.and.arrow.right.fill"]]
    
    var userType = UserDefaults.standard.integer(forKey: "userType")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageHeaderView = HeaderView.loadNib()
        self.view.addSubview(self.imageHeaderView)
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "MenuCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "MenuCell")
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = 60
        tableView.separatorColor = UIColor.white
        imageViewHeight.constant = imageHeaderView.frame.size.height
    }
}

extension MenuVC : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userType == 0 ? menusClientAdmin.count : menusClient.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        if userType == 0 {
            cell.setData(menusClientAdmin[indexPath.row] as [String :AnyObject])
        }else{
            cell.setData(menusClient[indexPath.row] as [String :AnyObject])
        }
        return cell
    }
}

extension MenuVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.menuHandler(index: indexPath.row + 1 )
    }
}
