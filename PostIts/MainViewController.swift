//
//  MainViewController.swift
//  PostIts
//
//  Created by SASAKIAI on 2016/07/27.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//

import UIKit
import RealmSwift

class PostItsModel: Object {
    dynamic var id: Int16 = 0
    dynamic var color: Int8 = 0
    dynamic var content: String = ""
    dynamic var creatTime = NSDate()
    dynamic var updateTime = NSDate()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class MainViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    var backgroundImageView: BackGroundImageView!

    // デフォルトRealmを取得
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // scrollview の設定
        mainScrollView.delegate = self
        mainScrollView.minimumZoomScale = 0.25
        mainScrollView.maximumZoomScale = 2.0
        
        // backgroundImageView の設定
        backgroundImageView = BackGroundImageView(image: UIImage(named: "IMG_1331.jpg"))
        backgroundImageView.userInteractionEnabled = true
        
        mainScrollView.addSubview(backgroundImageView)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        //KVO を登録する処理
        backgroundImageView.addObserver(self, forKeyPath: "touchPoint", options: [.New, .Old], context: nil)
    }
    
    override func viewDidDisappear(animated: Bool){
        //KVO を削除する処理
        backgroundImageView.removeObserver(self, forKeyPath: "touchPoint")
    }
    
    //KVO backgroundImageView を touch した時に呼ばれる
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        print(keyPath)  //debug code
        print(object)   //debug code
        print(change)   //debug code

        let newPostIts = PostItsModel()
        newPostIts.id = 0
        newPostIts.color = 0
        newPostIts.creatTime = NSDate()
        newPostIts.updateTime = newPostIts.creatTime
        
        // Realmにデータを永続化
        //プライマリーキー id の値がすでに存在するなら、更新、存在しないなら追加
        try! realm.write {
            realm.add(newPostIts, update: true)
        }
        
        //backgroundImageView に PostItsImageView を追加する
        
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
            max((mainScrollView.frame.height - backgroundImageView.frame.height)/2, 0),
            max((mainScrollView.frame.width - backgroundImageView.frame.width)/2, 0),
            0,
            0
        );
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

