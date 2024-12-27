//
//  View+Extensions.swift
//  MVC-Swift
//
//  Created by NilarWin on 09/08/2022.
//

import Foundation
import UIKit
import SwiftValidator
import MobileCoreServices
import UniformTypeIdentifiers
import Alamofire
import SwiftyJSON

extension UIView {
    static func instanceFromNib<T>() -> T? {
        return UINib(nibName: String(describing: T.self), bundle: nil).instantiate(withOwner: nil, options: nil).first as? T
    }
    
    class func loadNib<T: UIView>(_ viewType: T.Type) -> T {
        let className = String.className(viewType)
        return Bundle(for: viewType).loadNibNamed(className, owner: nil, options: nil)!.first as! T
    }
    
    class func loadNib() -> Self {
        return loadNib(self)
    }
    
    func constrainHeight(constant: CGFloat) {
        constraints.forEach {
            if $0.firstAttribute == .height {
                self.removeConstraint($0)
            }
        }
        
        heightAnchor.constraint(equalToConstant: constant).isActive = true
    }
}

func mimeType(for path: String) -> String {
    let pathExtension = URL(fileURLWithPath: path).pathExtension as NSString
    if let type = UTType(filenameExtension: pathExtension as String) {
        if let mimetype = type.preferredMIMEType {
            return mimetype as String
        }
    }
    return "application/octet-stream"
}

func formattedDateFromString(dateString: String, withFormat format: String) -> String? {
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "yyyy-MM-dd"
    if let date = inputFormatter.date(from: dateString) {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = format
        return outputFormatter.string(from: date)
    }
    return nil
}

extension String {
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
}
