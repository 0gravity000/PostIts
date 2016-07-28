//
//  BackGroundImageView.swift
//  PostIts
//
//  Created by SASAKIAI on 2016/07/28.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//

import UIKit

class BackGroundImageView: UIImageView {

    dynamic var touchPoint: CGPoint = CGPoint.init()
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

//    override init() {
//        super.init()
//        addObserver(self, forKeyPath: "prop", options: [.New, .Old], context: nil)
//    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("touch Ended!!! ")    //debug code
        let touch = touches.first
        self.touchPoint = touch!.locationInView(self)
        print("touchPoint = \(self.touchPoint)") //debug code
        
    }

}
