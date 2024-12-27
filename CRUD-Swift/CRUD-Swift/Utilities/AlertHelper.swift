//
//  AlertHelper.swift
//  MVC-Swift
//
//  Created by NilarWin on 09/08/2022.
//

import Foundation
import UIKit

struct AlertHelper {
    static func present(in parent: UIViewController,
                        title: String,
                        message: String,
                        style: UIAlertController.Style = .alert,
                        actionTitle: String? = "OK",
                        actionStyle: UIAlertAction.Style = .default,
                        handler: (() -> Void)? = nil) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let okAction = UIAlertAction(title: actionTitle, style: actionStyle) { _ in
            handler?()
        }
        alertController.addAction(okAction)
        
        parent.present(alertController, animated: true, completion: nil)
    }
}
