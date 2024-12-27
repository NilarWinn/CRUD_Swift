//
//  Validation+Extensions.swift
//  Bulletin-Board-Swift
//
//  Created by NilarWin on 20/10/2022.
//
import Foundation
import UIKit
import SwiftValidator
import MobileCoreServices
import UniformTypeIdentifiers
import Alamofire
import SwiftyJSON

extension UIViewController: ValidationDelegate {
    public func validationSuccessful() {
        UserDefaults.standard.set(1, forKey: "validateStatus")
    }
    
    public func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        UserDefaults.standard.set(0, forKey: "validateStatus")
    }
    
    func logout() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
        self.navigationController?.pushViewController(vc!, animated: true)
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
        let token = UserDefaults.standard.string(forKey: "token")
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer " + (token ?? "")
        ]
        
        AF.request("\(Network.HOSTAPI)logout", method : .get, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: ResponseStatus.self) {_ in }
    }
}
