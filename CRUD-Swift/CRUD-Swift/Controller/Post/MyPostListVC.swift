//
//  MyPostListVC.swift
//  Bulletin-Board-Swift
//
//  Created by NilarWin on 18/10/2022.
//

import Foundation
import UIKit
import DropDown
import JJFloatingActionButton
import Alamofire
import SwiftyJSON
import SVProgressHUD

class MyPostListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyBody: UILabel!
    @IBOutlet weak var emptyTitle: UILabel!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    var postArray : [Post] = [Post]()
    let dropDown = DropDown()
    fileprivate let actionButton = JJFloatingActionButton()
    var searchClick = true
    var delegate: MenuDelegate?
    var token = ""
    var startIndex = 0
    var endIndex = 0
    var userTypeLocal = UserDefaults.standard.integer(forKey: "userType")
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "PostListCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "PostListCell")
        tableView.separatorStyle = .none
        setUpFloadingButton()
        token = UserDefaults.standard.string(forKey: "token") ?? ""
        if Connectivity.isConnectedToInternet {
            SVProgressHUD.show()
            postArray = []
            getMyPostList()
        } else {
            DispatchQueue.main.async {
                self.view.makeToast(Constants.networkError, duration: 3.0, position: .bottom)
            }
        }
        CheckSearchView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 240
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: Any) {
        startIndex = 0
        postArray = []
        getMyPostList()
        refreshControl.endRefreshing()
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
            self.searchTextField.text = ""
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
    
    func getMyPostList() {
        Service.shared.getMyPostList(token: token, startIndex: "\(startIndex)") { (response)-> Void in
            let result = response
            SVProgressHUD.dismiss()
            if result.status == "success" {
                let resultData = result.data!
                self.endIndex = resultData.count > 0 ? self.startIndex + 1 : 0
                for i in resultData {
                    let data  = i
                    self.postArray.append(data)
                }
            }else {
                AlertHelper.present(in: self, title: "Error", message: result.message ?? "Error Message", actionTitle: "OK", handler: {
                    if(result.message == "Unauthorized") {
                        self.logout()
                    }
                })
            }
            self.tableView.reloadData()
            self.emptyView.isHidden = self.postArray.count == 0 ? false : true
            self.tableView.isHidden = self.postArray.count == 0 ? true : false
        }
    }
    
    @IBAction func search(_ sender: Any) {
        self.searchClick = true
        startIndex = 0
        self.postArray = []
        getSearchMyPost(searchData: searchTextField.text ?? "", startIndex: startIndex)
        CheckSearchView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let showPagination = checkPagination(index: indexPath.row, array: postArray, tableView: self.tableView)
        if showPagination {
            startIndex += 1
            if searchClick {
                getMyPostList()
            }else{
                getSearchMyPost(searchData: searchTextField.text ?? "", startIndex: startIndex)
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostListCell", for: indexPath)as! PostListCell
        if (postArray.count > 0){
            cell.postTitle.text = postArray[indexPath.row].title
            cell.postDescription.text = postArray[indexPath.row].description
            cell.userType.text = "User \(String(postArray[indexPath.row].posted_by.type!))"
            cell.postCellView.layer.cornerRadius = 8
            cell.editButtonClick.tag = indexPath.row
            cell.editButtonClick.addTarget(self, action: #selector(setUpDropDownList( sender:)), for: .touchUpInside)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc func setUpDropDownList(sender: UIButton){
        if self.postArray[sender.tag].status == "1" {
            self.dropDown.dataSource = ["Edit", "Delete"]
        }else{
            self.dropDown.dataSource = ["Edit"]
        }
        self.dropDown.anchorView = sender
        dropDown.bottomOffset = CGPoint(x: -50, y: sender.frame.size.height)
        dropDown.show()
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let _ = self else { return }
            if index == 0 {
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CreatePostVC") as? CreatePostVC
                vc?.editClick = true
                vc?.selectedPost = self!.postArray[sender.tag]
                self?.navigationController?.pushViewController(vc!, animated: true)
            }else{
                let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this?", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: { [self] (action) -> Void in
                    let index = sender.tag
                    self!.deletePost(index: index)
                })
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                dialogMessage.addAction(ok)
                dialogMessage.addAction(cancel)
                self!.present(dialogMessage, animated: true, completion: nil)
            }
        }
    }
    
    func getSearchMyPost(searchData: String, startIndex: Int) {
        Service.shared.getSearchMyPostList(token: token, startIndex: "\(startIndex)", searchData: searchData) { (response)-> Void in
            let result = response
            SVProgressHUD.dismiss()
            if result.status == "success" {
                let resultData = result.data!
                for i in resultData {
                    let data  = i
                    self.postArray.append(data)
                }
            }else {
                AlertHelper.present(in: self, title: "Error", message: result.message ?? "Error Message", actionTitle: "OK", handler: {
                    if(result.message == "Unauthorized") {
                        self.logout()
                    }
                })
            }
            self.tableView.reloadData()
            self.emptyView.isHidden = self.postArray.count == 0 ? false : true
            self.tableView.isHidden = self.postArray.count == 0 ? true : false
        }
    }
    
    func deletePost(index: Int) {
        let parameter = [
            "post_id" : self.postArray[index].id
        ]
        Service.shared.deletePost(token: token, parameter: parameter as Parameters) { (response)-> Void in
            let result = response
            SVProgressHUD.dismiss()
            if result.status == "success" {
                self.startIndex = 0
                self.postArray = []
                self.getMyPostList()
                self.view.makeToast(result.message, duration: 3.0, position: .bottom)
            }else {
                AlertHelper.present(in: self, title: "Error", message: result.message ?? "Error Message", actionTitle: "OK", handler: {
                    if(result.message == "Unauthorized") {
                        self.logout()
                    }
                })
            }
        }
    }
    
    func CheckSearchView() {
        searchButtonConstraint.constant = searchClick ? 0 : 50
        searchButton.frame.size.height = searchClick ? 0 : 50
        searchView.isHidden = searchClick
        searchView.layoutIfNeeded()
        self.view.endEditing(true)
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
    
    @IBAction func showMenu(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
