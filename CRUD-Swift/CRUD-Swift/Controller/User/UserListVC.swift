//
//  UserListVC.swift
//  MVC-Swift
//
//  Created by NilarWin on 17/08/2022.
//

import UIKit
import DropDown
import JJFloatingActionButton
import Alamofire
import SwiftyJSON
import SVProgressHUD

class UserListVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTextfield: UITextField!
    @IBOutlet weak var emptyBody: UILabel!
    @IBOutlet weak var emptyTitle: UILabel!
    @IBOutlet weak var emptyView: UIView!
    var userArray:[User] = [User]()
    let dropDown = DropDown()
    fileprivate let actionButton = JJFloatingActionButton()
    var searchClick = true
    var token = UserDefaults.standard.string(forKey: "token") ?? ""
    var startIndex = 0
    var endIndex = 0
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "UserListCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "UserListCell")
        tableView.separatorStyle = .none
        if Connectivity.isConnectedToInternet {
            SVProgressHUD.show()
            userArray = []
            getUserList()
        } else {
            DispatchQueue.main.async {
                self.view.makeToast(Constants.networkError, duration: 3.0, position: .bottom)
            }
        }
        setUpFloadingButton()
        CheckSearchView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: Any) {
        startIndex = 0
        userArray = []
        getUserList()
        refreshControl.endRefreshing()
    }
    
    func getUserList() {
        Service.shared.getUserList(token: token, startIndex: "\(startIndex)", completion: {(response) -> Void in
            let result = response
            SVProgressHUD.dismiss()
            if result.status == "success" {
                let resultData = result.data!
                self.endIndex = resultData.count > 0 ? self.startIndex + 1 : 0
                for i in resultData {
                    let data  = i
                    self.userArray.append(data)
                }
            }else {
                AlertHelper.present(in: self, title: "Error", message: result.message ?? "Error Message", actionTitle: "OK", handler: {
                    if(result.message == "Unauthorized") {
                        self.logout()
                    }
                })
            }
            self.tableView.reloadData()
            self.emptyView.isHidden = self.userArray.count == 0 ? false : true
            self.tableView.isHidden = self.userArray.count == 0 ? true : false
        })
    }
    
    func setUpFloadingButton() {
        let myColor = UIColor(hex: 0x05AAD1)
        actionButton.buttonColor = myColor
        let configuration = JJItemAnimationConfiguration()
        configuration.itemLayout = JJItemLayout { items, actionButton in
            var previousItem: JJActionItem?
            for item in items {
                let previousView = previousItem ?? actionButton
                item.bottomAnchor.constraint(equalTo: previousView.topAnchor, constant: -10).isActive = true
                item.circleView.centerXAnchor.constraint(equalTo: actionButton.centerXAnchor).isActive = true
                previousItem = item
            }
        }
        actionButton.itemAnimationConfiguration = configuration
        actionButton.addItem(title: "Search", image: UIImage(systemName: "magnifyingglass")) { item in
            self.searchClick = false
            self.CheckSearchView()
        }
        view.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            actionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
            actionButton.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor, constant: -10).isActive = true
        } else {
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
            actionButton.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor, constant: -10).isActive = true
        }
    }
    
    func CheckSearchView() {
        searchTextfield.text! = ""
        searchButtonConstraint.constant = searchClick ? 0 : 50
        searchButton.frame.size.height = searchClick ? 0 : 50
        searchView.isHidden = searchClick
        searchTextfield.isHidden = searchClick
        searchView.layoutIfNeeded()
    }
    
    @IBAction func searchAction(_ sender: Any) {
        searchClick = true
        startIndex = 0
        userArray = []
        getSearchUser(searchData: searchTextfield.text!, startIndex: startIndex)
        CheckSearchView()
    }
    
    @IBAction func backAction(_ sender: Any) {
        let vc = ContainerVC()
        DispatchQueue.main.async {
            self.navigationController?.isNavigationBarHidden = true
        }
        self.navigationController?.pushViewController(vc, animated: true)
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let showPagination = checkPagination(index: indexPath.row, array: userArray, tableView: self.tableView)
        if showPagination {
            startIndex += 1
            if searchClick {
                getUserList()
            }else{
                getSearchUser(searchData: searchTextfield.text!, startIndex: startIndex)
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListCell", for: indexPath) as! UserListCell
        if userArray.count > 0 {
            cell.userCellView.layer.cornerRadius = 8
            cell.name.text = userArray[indexPath.row].name
            cell.email.text = userArray[indexPath.row].email
            cell.phone.text = userArray[indexPath.row].phone
            cell.address.text = userArray[indexPath.row].address
            let dob = userArray[indexPath.row].dob
            cell.dob.text = dob != nil ?  formattedDateFromString(dateString: String(dob!.split(separator: "T")[0]), withFormat: "dd-MM-yyyy") : ""
            cell.address.sizeToFit()
            cell.email.sizeToFit()
            cell.emailStackViewHeight.constant = cell.email.frame.size.height
            cell.addressStackViewheight.constant = cell.address.frame.size.height
            cell.editButton.tag = indexPath.row
            cell.editButton.addTarget(self, action: #selector(setUpDropDownList( sender:)), for: .touchUpInside)
        }
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func checkPagination(index: Int, array: [Any], tableView: UITableView) -> Bool {
        let count = array.count
        if endIndex > startIndex {
            let lastElement = count - 1
            if index == lastElement {
                let spinner = UIActivityIndicatorView()
                spinner.style = UIActivityIndicatorView.Style.large
                spinner.startAnimating()
                spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
                tableView.tableFooterView = spinner
                tableView.tableFooterView?.isHidden = false
                return true
            }
        }else{
            tableView.tableFooterView?.isHidden = true
            return false
        }
        return false
    }
    
    @objc func setUpDropDownList(sender: UIButton){
        self.dropDown.dataSource = ["Edit", "Delete"]
        self.dropDown.anchorView = sender
        dropDown.bottomOffset = CGPoint(x: -50, y: sender.frame.size.height)
        dropDown.show()
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let _ = self else { return }
            if index == 0 {
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CreateUserVC") as? CreateUserVC
                vc?.editUser = true
                vc?.selectedUser = self!.userArray[sender.tag]
                self?.navigationController?.pushViewController(vc!, animated: true)
            }else{
                let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this?", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                    let index = sender.tag
                    self!.deleteUser(index: index)
                })
                let cancel = UIAlertAction(title: "Cancel", style: .cancel,handler: nil)
                dialogMessage.addAction(ok)
                dialogMessage.addAction(cancel)
                self!.present(dialogMessage, animated: true, completion: nil)
            }
        }
    }
    
    func deleteUser(index: Int) {
        let parameter = [
            "user_id" : (self.userArray[index])._id!
        ]
        Service.shared.deleteUser(token: token, parameter: parameter as Parameters, completion: { (response) -> Void in
            let result = response
            SVProgressHUD.dismiss()
            if result.status == "success" {
                self.userArray.remove(at: index)
                self.tableView.reloadData()
                self.emptyView.isHidden = self.userArray.count == 0 ? false : true
                self.tableView.isHidden = self.userArray.count == 0 ? true : false
                self.view.makeToast(result.message, duration: 3.0, position: .bottom)
            }else {
                AlertHelper.present(in: self, title: "Error", message: result.message ?? "Error Message", actionTitle: "OK", handler: {
                    if(result.message == "Unauthorized") {
                        self.logout()
                    }
                })
            }
        })
    }
    
    func getSearchUser(searchData: String, startIndex: Int) {
        Service.shared.getSearchUserList(token: token, startIndex: "\(startIndex)", searchData: searchData, completion: { (response) -> Void in
            let result = response
            SVProgressHUD.dismiss()
            if result.status == "success" {
                let resultData = result.data!
                self.endIndex = resultData.count > 0 ? self.startIndex + 1 : 0
                for i in resultData {
                    let data  = i
                    self.userArray.append(data)
                }
            } else if result.message != nil{
                AlertHelper.present(in: self, title: "Error", message: result.message ?? "Error Message", actionTitle: "OK", handler: {
                    if(result.message == "Unauthorized") {
                        self.logout()
                    }
                })
            }
            self.tableView.reloadData()
            self.emptyView.isHidden = self.userArray.count == 0 ? false : true
            self.tableView.isHidden = self.userArray.count == 0 ? true : false
        })
    }
}
