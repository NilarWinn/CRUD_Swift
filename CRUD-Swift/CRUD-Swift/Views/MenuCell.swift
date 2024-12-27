//
//  MenuCell.swift
//  MVC-Swift
//
//  Created by NilarWin on 12/08/2022.
//

import Foundation
import UIKit

class MenuCell: UITableViewCell {
    
    @IBOutlet weak var imgMenu: UIImageView!
    @IBOutlet weak var txtMenu: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setData(_ data:[String:AnyObject] ) {
        if let cellTxt = data["txtMenu"] as? String
        {
            self.txtMenu.text = cellTxt
        }
        if let cellImg = data["imgMenu"] as? String
        {
            self.imgMenu.image = UIImage(systemName: cellImg)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
