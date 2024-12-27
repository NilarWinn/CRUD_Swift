//
//  LoadingView.swift
//  MVC-Swift
//
//  Created by NilarWin on 09/08/2022.
//

import UIKit

class LoadingView: UIView {
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    enum Configuration {
        static let cornerRadius: CGFloat = 10.0
        static let alpha: CGFloat = 0.8
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = Configuration.cornerRadius
        alpha = Configuration.alpha
        isHidden = true
    }
    
    static func initToView(_ view: UIView, loadingText: String = "Loading...") -> LoadingView {
        
        guard let loadingView : LoadingView = UIView.instanceFromNib() else {
            fatalError("Unable to allocate Loading View")
        }
        
        loadingView.loadingLabel.text = loadingText
        loadingView.isHidden = true
        loadingView.center = view.center
        view.addSubview(loadingView)
        
        return loadingView
    }
    
    func show() {
        isHidden = false
    }
    
    func hide() {
        isHidden = true
    }
}
