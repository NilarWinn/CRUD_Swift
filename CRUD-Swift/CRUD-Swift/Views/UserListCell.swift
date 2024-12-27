//
//  UserListCell.swift
//  MVC-Swift
//
//  Created by NilarWin on 19/08/2022.
//

import UIKit

class UserListCell: UITableViewCell {
    @IBOutlet weak var userCellView: UIView!
    @IBOutlet weak var dotImage: UIImageView!
    @IBOutlet weak var dob: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var phoneStackView: UIStackView!
    @IBOutlet weak var addressStackViewheight: NSLayoutConstraint!
    @IBOutlet weak var emailStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var editButton: UIButton!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
