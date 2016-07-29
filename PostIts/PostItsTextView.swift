//
//  PostItsTextView.swift
//  PostIts
//
//  Created by SASAKIAI on 2016/07/29.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//

import UIKit

class PostItsTextView: UITextView {

    dynamic var touchPoint: CGPoint = CGPoint.init()

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("touch PostIts TextView!!! ")    //debug code
        let touch = touches.first
        self.touchPoint = touch!.locationInView(self)
        print("touchPoint = \(self.touchPoint)") //debug code
        
    }

}
