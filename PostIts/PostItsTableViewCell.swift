//
//  PostItsTableViewCell.swift
//  PostIts
//
//  Created by SASAKIAI on 2016/07/28.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//

import UIKit

class PostItsTableViewCell: UITableViewCell {

    @IBOutlet weak var updatetimeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
