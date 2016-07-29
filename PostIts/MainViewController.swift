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
    
//    var backgroundImageView: BackGroundImageView!
    var backgroundImageView = BackGroundImageView()
    var modeFlag: Int8 = 1  //1:select, 2:add, 3: remove
    
    @IBOutlet weak var mainScrollView: UIScrollView!

    @IBOutlet weak var selectPostItBarButton: UIBarButtonItem!
    @IBOutlet weak var addPostItBarButton: UIBarButtonItem!
    @IBOutlet weak var removePostItBarButton: UIBarButtonItem!
    
    @IBAction func pushSelectPostItBarButton(sender: AnyObject) {
        self.modeFlag = 1
        configureBarItemState()
    }
    @IBAction func pushAddPostItBarButton(sender: AnyObject) {
        self.modeFlag = 2
        configureBarItemState()
    }

    @IBAction func pushRemovePostItBarButton(sender: AnyObject) {
        self.modeFlag = 3
        configureBarItemState()
    }
    
    
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
        
        //barItemButtonの初期化
        configureBarItemState()
        
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

        //モードごとの処理
        if self.modeFlag == 1 {         //1:選択モード
        } else if self.modeFlag == 2 {  //2:追加モード
            //Realmデータ新規作成
            let newPostIts = PostItsModel()
            newPostIts.id = 0
            newPostIts.color = 0
            newPostIts.creatTime = NSDate()
            newPostIts.updateTime = newPostIts.creatTime
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            newPostIts.content = dateFormatter.stringFromDate(newPostIts.creatTime)
            
            // Realmにデータを永続化
            //プライマリーキー id の値がすでに存在するなら、更新、存在しないなら追加
            try! realm.write {
                realm.add(newPostIts, update: true)
            }
            
            //backgroundImageView に postItsTextView を追加する
            let postItsTextView = PostItsTextView()
            postItsTextView.tag = Int(newPostIts.id)
            postItsTextView.text = newPostIts.content
            postItsTextView.frame = CGRectMake(backgroundImageView.touchPoint.x, backgroundImageView.touchPoint.y, 100, 100);

            postItsTextView.userInteractionEnabled = true
            
            mainScrollView.addSubview(postItsTextView)
            
        } else if self.modeFlag == 3 {  //3:削除モード
        } else if self.modeFlag == 4 {  //4:移動モード
        }
        
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

    private func configureBarItemState() {
        if self.modeFlag == 1 {
            print("mode:select")    //debug code
//            self.selectPostItBarButton.enabled = true
//            self.addPostItBarButton.enabled = false
//            self.removePostItBarButton.enabled = false
        } else if self.modeFlag == 2 {
            print("mode:add")    //debug code
//            self.selectPostItBarButton.enabled = false
//            self.addPostItBarButton.enabled = true
//            self.removePostItBarButton.enabled = false
        } else if self.modeFlag == 3 {
            print("mode:remove")    //debug code
//            self.selectPostItBarButton.enabled = false
//            self.addPostItBarButton.enabled = false
//            self.removePostItBarButton.enabled = true
        } else if self.modeFlag == 4 {  //4:移動モード
            print("mode:move")    //debug code
        }
    
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

