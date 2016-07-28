//
//  ViewController.swift
//  PostIts
//
//  Created by SASAKIAI on 2016/07/27.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    var backgroundImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mainScrollView.delegate = self
        mainScrollView.minimumZoomScale = 0.25
        mainScrollView.maximumZoomScale = 2.0
        
        backgroundImageView = UIImageView(image: UIImage(named: "IMG_1331.jpg"))
        mainScrollView.addSubview(backgroundImageView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        if let size = mainImageView.image?.size {
//            // imageViewのサイズがscrollView内に収まるように調整
//            let wrate = mainScrollView.frame.width / size.width
//            let hrate = mainScrollView.frame.height / size.height
//            let rate = min(wrate, hrate, 1)
//            mainImageView.frame.size = CGSizeMake(size.width * rate, size.height * rate)
            
            // contentSizeを画像サイズに設定
            mainScrollView.contentSize = backgroundImageView.frame.size
            // 初期表示のためcontentInsetを更新
            updateScrollInset()
//        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        // ズームのために要指定
        return backgroundImageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        // ズームのタイミングでcontentInsetを更新
        updateScrollInset()
    }
    
    private func updateScrollInset() {
        // imageViewの大きさからcontentInsetを再計算
        // なお、0を下回らないようにする
        mainScrollView.contentInset = UIEdgeInsetsMake(
            max((backgroundImageView.frame.height - backgroundImageView.frame.height)/2, 0),
            max((backgroundImageView.frame.width - backgroundImageView.frame.width)/2, 0),
            0,
            0
        );
    }
    
}

