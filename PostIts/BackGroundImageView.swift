//
//  BackGroundImageView.swift
//  PostIts
//
//  Created by SASAKIAI on 2016/07/28.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//

import UIKit

class BackGroundImageView: UIImageView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("touch Ended!!! ")
    }

}
