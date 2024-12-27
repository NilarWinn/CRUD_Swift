//
//  HeaderView.swift
//  MVC-Swift
//
//  Created by NilarWin on 15/08/2022.
//

import Foundation
import UIKit

class HeaderView: UIView {
    
    @IBOutlet weak var role: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userName.text = UserDefaults.standard.string(forKey: "name")
        role.text = UserDefaults.standard.integer(forKey: "userType") == 0 ? "admin" : "user"
        self.profileImage.layer.cornerRadius = self.profileImage.bounds.size.height / 2
        self.profileImage.clipsToBounds = true
        let profile = UserDefaults.standard.string(forKey: "profile")
        let url = URL(string: "\(Network.IMGAPI)\(profile!)")        
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                  let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                  let data = data, error == nil,
                  let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async() { () -> Void in
                self.profileImage.image = image
            }
        }.resume()
    }
}
extension UIImage {
    convenience init?(url: URL?) {
        guard let url = url else { return nil }
        
        do {
            self.init(data: try Data(contentsOf: url))
        } catch {
            return nil
        }
    }
}
