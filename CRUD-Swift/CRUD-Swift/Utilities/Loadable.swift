//
//  Loadable.swift
//  MVC-Swift
//
//  Created by NilarWin on 09/08/2022.
//

import Foundation
import UIKit

protocol Loadable {
    var loadingView: LoadingView { get }
    
    func showLoadingView()
    func hideLoadingView()
}

extension Loadable where Self: UIViewController {
    func showLoadingView() {
        view.isUserInteractionEnabled = false
        loadingView.show()
    }
    
    func hideLoadingView() {
        view.isUserInteractionEnabled = true
        view.endEditing(true)
        loadingView.hide()
    }
}
