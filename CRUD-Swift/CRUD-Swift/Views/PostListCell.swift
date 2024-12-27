//
//  PostListCell.swift
//  MVC-Swift
//
//  Created by NilarWin on 11/08/2022.
//

import UIKit

class PostListCell: UITableViewCell  {
    
    @IBOutlet weak var postCellView: UIView!
    @IBOutlet weak var editButtonClick: UIButton!
    @IBOutlet weak var userType: UILabel!
    @IBOutlet weak var postDescription: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var dotImage: UIImageView!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
