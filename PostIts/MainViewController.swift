//
//  MainViewController.swift
//  PostIts
//
//  Created by SASAKIAI on 2016/07/27.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//

import UIKit
import RealmSwift
import StoreKit

class PostItsModel: Object {
    dynamic var id: String = ""
    dynamic var tagNo: Int16 = 0
    dynamic var color: Int = 0
    dynamic var content: String = ""
    dynamic var creatTime = NSDate()
    dynamic var updateTime = NSDate()
    dynamic var posX: Float = 0.0
    dynamic var posY: Float = 0.0
    dynamic var isVisible: Bool = true
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class MainViewController: UIViewController, UIScrollViewDelegate, UITextViewDelegate, PostItsPurchaseManagerDelegate {
    
//    var backgroundImageView: BackGroundImageView!
    var backgroundImageView = BackGroundImageView()
    var modeFlag: Int = 1  //1:edit, 2:add, 3: remove 4:move 5:config
    var isMovingFlag: Bool = false
    var movingTextView: UITextView! = nil
    let POSTIT_WIDTH: CGFloat = 300.0
    let POSTIT_HIGHT: CGFloat = 200.0
    let POSTIT_FONT: UIFont = UIFont(name:"HelveticaNeue-Bold",size:24)!
    
    @IBOutlet weak var mainScrollView: UIScrollView!

    @IBOutlet weak var colorPostItBarButton: UIBarButtonItem!
    @IBOutlet weak var selectPostItBarButton: UIBarButtonItem!
    @IBOutlet weak var addPostItBarButton: UIBarButtonItem!
    @IBOutlet weak var removePostItBarButton: UIBarButtonItem!
    @IBOutlet weak var movePostItBarButton: UIBarButtonItem!
    @IBOutlet weak var configPostItBarButton: UIBarButtonItem!
    @IBOutlet weak var showListBarButton: UIBarButtonItem!

    @IBAction func pushColorPostItBarButton(sender: AnyObject) {
        configurePostItBackgroundColor()

        //このタイミングでNSUserdefaultsを使ってデータを保存する
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if (appDelegate.selectedPostItColor == postItBackgroundColor.yellow) {
            defaults.setInteger(postItBackgroundColor.yellow.rawValue, forKey: "selectedPostItColor")
        } else if (appDelegate.selectedPostItColor == postItBackgroundColor.blue) {
            defaults.setInteger(postItBackgroundColor.blue.rawValue, forKey: "selectedPostItColor")
        } else if (appDelegate.selectedPostItColor == postItBackgroundColor.green) {
            defaults.setInteger(postItBackgroundColor.green.rawValue, forKey: "selectedPostItColor")
        } else if (appDelegate.selectedPostItColor == postItBackgroundColor.orange) {
            defaults.setInteger(postItBackgroundColor.orange.rawValue, forKey: "selectedPostItColor")
        } else if (appDelegate.selectedPostItColor == postItBackgroundColor.pink) {
            defaults.setInteger(postItBackgroundColor.pink.rawValue, forKey: "selectedPostItColor")
        } else if (appDelegate.selectedPostItColor == postItBackgroundColor.purple) {
            defaults.setInteger(postItBackgroundColor.purple.rawValue, forKey: "selectedPostItColor")
        }
    }

    @IBAction func pushSelectPostItBarButton(sender: AnyObject) {
        //移動中の場合は、モード遷移しない
        if (self.isMovingFlag != true) {
            self.modeFlag = 1
            configureBarItemState()
        }
    }
    @IBAction func pushAddPostItBarButton(sender: AnyObject) {
        //移動中の場合は、モード遷移しない
        if (self.isMovingFlag != true) {
            self.modeFlag = 2
            configureBarItemState()
        }
    }

    @IBAction func pushRemovePostItBarButton(sender: AnyObject) {
        //移動中の場合は、モード遷移しない
        if (self.isMovingFlag != true) {
            self.modeFlag = 3
            configureBarItemState()
        }
    }
    
    @IBAction func pushMovePostItBarButton(sender: AnyObject) {
        self.modeFlag = 4
        configureBarItemState()
    }
    
    @IBAction func pushConfigPostItBarButton(sender: AnyObject) {
        //modal画面へ移動するので、呼ばれない
        self.modeFlag = 5
        configureBarItemState()
    }
    
    // デフォルトRealmを取得
    let realm = try! Realm()
    var sortedRealm: Results<PostItsModel>? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // scrollview の設定
        mainScrollView.delegate = self
        mainScrollView.minimumZoomScale = 0.25
        mainScrollView.maximumZoomScale = 2.0
        
        // backgroundImageView の設定
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
        backgroundImageView = BackGroundImageView(image: configureBackgroungImg(appDelegate.selectedBackgroundImg))
        backgroundImageView.tag = 1
        backgroundImageView.userInteractionEnabled = true
        mainScrollView.addSubview(backgroundImageView)
        
        //barItemButtonの初期化
        configureBarItemState()
        self.colorPostItBarButton.tintColor = configureUIColor(appDelegate.selectedPostItColor.rawValue)
        self.showListBarButton.tintColor = UIColor.blueColor()
        
        //RealmデータからPostItsTextViewを作成 初期化
        //Realmデータのソート creatTime 昇順 小さいものから大きいものへ 0,1,2,...
        self.sortedRealm = self.realm.objects(PostItsModel).sorted("creatTime", ascending: true)
        for postIt in self.sortedRealm! {
            //backgroundImageView に postItsTextView を追加する
            let postItsTextView = PostItsTextView()
            addPostItsTextViewToBackgroundImageView(postItsTextView, targetPostIt: postIt)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        // backgroundImageView の設定 再表示時のため
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
        backgroundImageView.image = configureBackgroungImg(appDelegate.selectedBackgroundImg)
        //指定の座標を表示 再表示時のため
        if (appDelegate.viewPosX != nil && appDelegate.viewPosY != nil) {
            mainScrollView.contentOffset = CGPointMake(CGFloat(appDelegate.viewPosX!) * mainScrollView.zoomScale,
                                                       CGFloat(appDelegate.viewPosY!) * mainScrollView.zoomScale)
            //座標をクリア
            appDelegate.viewPosX = nil
            appDelegate.viewPosY = nil
        }
        
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

        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
        //右下隅の補正処理
        var amendedBackgroundImageViewTouchPointX: CGFloat = 0.0
        var amendedBackgroundImageViewTouchPointY: CGFloat = 0.0
        //x補正
        print(backgroundImageView.touchPoint.x) //debug code
        print(POSTIT_WIDTH) //debug code
        print(backgroundImageView.frame.size.width / mainScrollView.zoomScale)  //debug code
        if (backgroundImageView.touchPoint.x + POSTIT_WIDTH >
            (backgroundImageView.frame.size.width / mainScrollView.zoomScale)) {
            amendedBackgroundImageViewTouchPointX = (backgroundImageView.frame.size.width / mainScrollView.zoomScale) - POSTIT_WIDTH
        } else {
            amendedBackgroundImageViewTouchPointX = backgroundImageView.touchPoint.x
        }
        //y補正
        print(backgroundImageView.touchPoint.y) //debug code
        print(POSTIT_HIGHT) //debug code
        print(backgroundImageView.frame.size.height / mainScrollView.zoomScale) //debug code
        if (backgroundImageView.touchPoint.y + POSTIT_HIGHT >
            (backgroundImageView.frame.size.height / mainScrollView.zoomScale)) {
            amendedBackgroundImageViewTouchPointY = (backgroundImageView.frame.size.height / mainScrollView.zoomScale) - POSTIT_HIGHT
        } else {
            amendedBackgroundImageViewTouchPointY = backgroundImageView.touchPoint.y
        }
        
        //モードごとの処理
        if (self.modeFlag == 1) {         //1:編集モード
            //特に何もしない
        } else if (self.modeFlag == 2) {  //2:追加モード
            //Realmデータのソート creatTime 昇順 小さいものから大きいものへ 0,1,2,...
            self.sortedRealm = self.realm.objects(PostItsModel).sorted("creatTime", ascending: true)
            print(self.sortedRealm) //debug code

            var executableFlag = true
            //制限チェック処理
            //制限解除キーは購入済みか
            if (appDelegate.isPurchasedLimitationReleaseKey == false) {
                //PostItsの数が10個か
                if (self.sortedRealm?.count >= 10) {
                    executableFlag = false
                    //alert表示
                    let ac = UIAlertController(title: NSLocalizedString("alertTitle_A001", comment: ""),
                                               message: NSLocalizedString("alertMessage_A001-1", comment: "")
                                               + "\n" + NSLocalizedString("alertMessage_A001-2", comment: ""),
                                               preferredStyle: .Alert)
                    //OK
                    let okAction = UIAlertAction(title: "OK", style: .Default, handler:{
                        // ボタンが押された時の処理
                        (action: UIAlertAction!) -> Void in
                    })
                    ac.addAction(okAction)
                    presentViewController(ac, animated: true, completion: nil)

                }
            }
            
            //制限解除キーは購入済み または、制限解除キー未購入だが10個以下の場合
            if (executableFlag == true) {
                //Realmデータ新規作成
                let newPostIt = PostItsModel()
                
                //tagNo算出 sortedRealm の順に割り振る
                if let realmLastObject = self.sortedRealm!.last {
                    newPostIt.tagNo = realmLastObject.tagNo + 1
                } else {
                    newPostIt.tagNo = 0
                }
                
                newPostIt.id = NSUUID().UUIDString
                newPostIt.color = appDelegate.selectedPostItColor.rawValue
                newPostIt.creatTime = NSDate()
                newPostIt.updateTime = newPostIt.creatTime
                newPostIt.posX = Float(amendedBackgroundImageViewTouchPointX)
                newPostIt.posY = Float(amendedBackgroundImageViewTouchPointY)
                newPostIt.isVisible = true
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = .MediumStyle
                dateFormatter.timeStyle = .MediumStyle
                //dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
                newPostIt.content = dateFormatter.stringFromDate(newPostIt.creatTime)
                
                //Realmにデータを永続化
                //プライマリーキー id の値がすでに存在するなら、更新、存在しないなら追加
                try! realm.write {
                    realm.add(newPostIt, update: true)
                }
                
                //backgroundImageView に postItsTextView を追加する
                let postItsTextView = PostItsTextView()
                addPostItsTextViewToBackgroundImageView(postItsTextView, targetPostIt: newPostIt)
            }
            
        } else if (self.modeFlag == 3) {  //3:削除モード
            //ここでは特に何もしない
            
        } else if (self.modeFlag == 4) {  //4:移動モード
            //移動中か判定 移動中にタッチされた時の処理
            if (self.isMovingFlag == true) {
                //移動中の場合、タッチした座標へPostItを移動する
                //Realmデータの座標を更新
                let movedPostIts = self.realm.objects(PostItsModel).filter("tagNo == \(self.movingTextView.tag)")
                for postIt in movedPostIts {
                    try! self.realm.write {
                        postIt.posX = Float(amendedBackgroundImageViewTouchPointX)
                        postIt.posY = Float(amendedBackgroundImageViewTouchPointY)
                    }
                    print(postIt)   //debug code
                }
                
                //TexvViewの移動
                for targetTextView in self.backgroundImageView.subviews {
                    if targetTextView.tag == self.movingTextView.tag {
                        targetTextView.frame = CGRectMake(CGFloat(amendedBackgroundImageViewTouchPointX),
                                                          CGFloat(amendedBackgroundImageViewTouchPointY),
                                                          POSTIT_WIDTH,
                                                          POSTIT_HIGHT);
                        targetTextView.alpha = 1.0
                        //タッチイベントを無視する
                        targetTextView.userInteractionEnabled = true
                    }
                }
                
                //後処理 移動中フラグを落とし、textviewバッファをクリア
                self.isMovingFlag = false
                self.movingTextView = nil
                
            }
        }
    }

    func commitButtonTapped (){
        self.view.endEditing(true)
    }
    
    //PostItsViewController へ画面遷移
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if (segue.identifier == "showPostItsList") {
            let postItsViewController:PostItsViewController = segue.destinationViewController as! PostItsViewController
            postItsViewController.realmObj = self.realm
        } else if (segue.identifier == "showCongiguration") {
            
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        // ズームのために要指定
        return backgroundImageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        // ズームのタイミングでcontentInsetを更新
        updateScrollInset()
    }
    
    
    // テキストビューにフォーカスが移った
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        print("textViewShouldBeginEditing : \(textView.text)")   //debug code
        
        if (self.modeFlag == 3) { //削除モードの時
            //ここで、ViewとRealmデータ削除処理を行う
            //Alert表示
            let alert: UIAlertController = UIAlertController(title: NSLocalizedString("alertTitle_A001", comment: ""),
                                                             message: NSLocalizedString("alertMessage_A002", comment: ""),
                                                             preferredStyle:  UIAlertControllerStyle.Alert)
            
            //Actionの設定
            // OKボタン
            let defaultAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("alertTitle_A002", comment: ""),
                                                             style: UIAlertActionStyle.Default,
                                                             handler:{
                // ボタンが押された時の処理
                (action: UIAlertAction!) -> Void in
                //Realmデータの削除 表示フラグを落とす
//                let removePostIts = self.realm.objects(PostItsModel).filter("tagNo == \(textView.tag)")
//                for postIts in removePostIts {
//                    try! self.realm.write {
//                        postIts.isVisible = false
//                    }
//                }
                
                let thisTextViewTag = textView.tag
                //Realmデータの削除
                let removePostIts = self.realm.objects(PostItsModel).filter("tagNo == \(textView.tag)")
                for postIt in removePostIts {
                    try! self.realm.write {
                        self.realm.delete(postIt)
                    }
                }
                //View削除
                textView.removeFromSuperview()
                
                //Realmデータのソート creatTime 昇順 小さいものから大きいものへ 0,1,2,...
                self.sortedRealm = self.realm.objects(PostItsModel).sorted("creatTime", ascending: true)
                print(self.sortedRealm) //debug code

                //全てのRealmの TagNoを振り直す
                let sortedPostIts = self.sortedRealm!
                var counter: Int16 = 0
                for sortedPostIt in sortedPostIts {
                    //Realmデータを creatTime 順に TagNo を降り直す
                    let postIts = self.realm.objects(PostItsModel).filter("creatTime == %@", sortedPostIt.creatTime)
                    print(postIts) //debug code
                    for postIt in postIts {
                        try! self.realm.write {
                            postIt.tagNo = counter
                        }
                    }
                    counter += 1
                }
                
                //全てのPostItsTextViewの TagNoを振り直す
                for targetTextView in self.backgroundImageView.subviews {
                    if targetTextView.tag > thisTextViewTag {
                       targetTextView.tag -= 1
                    }
                }
                print("OK")
                
            })
            // キャンセルボタン
            let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("alertTitle_A003", comment: ""),
                                                            style: UIAlertActionStyle.Cancel,
                                                            handler:{
                // ボタンが押された時の処理
                (action: UIAlertAction!) -> Void in
                print("Cancel")
            })
            
            //UIAlertControllerにActionを追加
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            
            //Alertを表示
            presentViewController(alert, animated: true, completion: nil)
            
            //以降テキスト編集処理を行わない
            return false
        } else if (self.modeFlag == 4) {    //移動モードの時
            self.isMovingFlag = true
            self.movingTextView = textView
            
            //textViewを半透明にする
            textView.alpha = 0.3
            //タッチイベントを無視する
            textView.userInteractionEnabled = false
            
            //以降テキスト編集処理を行わない
            return false
        } else if (self.modeFlag == 2) {    //追加モードの時
            //以降テキスト編集処理を行わない
            return false
        } else {     //編集モードの時
            //以降テキスト編集処理を行う
            return true
        }
    }

    //テキストビューが変更された
    func textViewDidChange(textView: UITextView) {
        print("textViewDidChange : \(textView.text)")   //debug code
    }
    
    // テキストビューからフォーカスが失われた
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        print("textViewShouldEndEditing : \(textView.text)")   //debug code

        if (self.modeFlag == 1) {   //編集モードの時
            //RealmデータのcontentとupdateTimeを更新
            let editPostIts = self.realm.objects(PostItsModel).filter("tagNo == \(textView.tag)")
            for postIt in editPostIts {
                try! self.realm.write {
                    postIt.content = textView.text
                    postIt.updateTime = NSDate()
                }
                print(postIt)   //debug code
            }
        }
        
        //キーボードを閉じる
        textView.resignFirstResponder()
        return true
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
    
    private func addPostItsTextViewToBackgroundImageView(postItsTextView: PostItsTextView, targetPostIt:PostItsModel) {
        
        postItsTextView.delegate = self
        postItsTextView.tag = Int(targetPostIt.tagNo)
        postItsTextView.text = targetPostIt.content + "\n"
//        postItsTextView.text = targetPostIt.tagNo.description + "\n" + targetPostIt.content + "\n"
        postItsTextView.frame = CGRectMake(CGFloat(targetPostIt.posX), CGFloat(targetPostIt.posY), POSTIT_WIDTH, POSTIT_HIGHT);
        postItsTextView.userInteractionEnabled = true
        postItsTextView.backgroundColor = configureUIColor(targetPostIt.color)
        postItsTextView.font = POSTIT_FONT
        
        // 仮のサイズでツールバー生成
        let kbToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        kbToolBar.barStyle = UIBarStyle.Default  // スタイルを設定
        kbToolBar.sizeToFit()  // 画面幅に合わせてサイズを変更
        
        // スペーサー
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        
        // 閉じるボタン
        let commitButton = UIBarButtonItem()
        commitButton.image = UIImage(named: "keyboard03.png")
        commitButton.target = self
        commitButton.action = #selector(MainViewController.commitButtonTapped)
        //            let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(MainViewController.commitButtonTapped))
        
        kbToolBar.items = [spacer, commitButton]
        postItsTextView.inputAccessoryView = kbToolBar
        
        backgroundImageView.addSubview(postItsTextView)
        
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
            self.selectPostItBarButton.tintColor = UIColor.redColor()
            self.addPostItBarButton.tintColor = UIColor.blueColor()
            self.removePostItBarButton.tintColor = UIColor.blueColor()
            self.movePostItBarButton.tintColor = UIColor.blueColor()
            self.configPostItBarButton.tintColor = UIColor.blueColor()
        } else if self.modeFlag == 2 {
            print("mode:add")    //debug code
            self.selectPostItBarButton.tintColor = UIColor.blueColor()
            self.addPostItBarButton.tintColor = UIColor.redColor()
            self.removePostItBarButton.tintColor = UIColor.blueColor()
            self.movePostItBarButton.tintColor = UIColor.blueColor()
            self.configPostItBarButton.tintColor = UIColor.blueColor()
        } else if self.modeFlag == 3 {
            print("mode:remove")    //debug code
            self.selectPostItBarButton.tintColor = UIColor.blueColor()
            self.addPostItBarButton.tintColor = UIColor.blueColor()
            self.removePostItBarButton.tintColor = UIColor.redColor()
            self.movePostItBarButton.tintColor = UIColor.blueColor()
            self.configPostItBarButton.tintColor = UIColor.blueColor()
        } else if self.modeFlag == 4 {  //4:移動モード
            print("mode:move")    //debug code
            self.selectPostItBarButton.tintColor = UIColor.blueColor()
            self.addPostItBarButton.tintColor = UIColor.blueColor()
            self.removePostItBarButton.tintColor = UIColor.blueColor()
            self.movePostItBarButton.tintColor = UIColor.redColor()
            self.configPostItBarButton.tintColor = UIColor.blueColor()
        } else if self.modeFlag == 5 {  //5:設定モード
            print("mode:config")    //debug code
            self.selectPostItBarButton.tintColor = UIColor.blueColor()
            self.addPostItBarButton.tintColor = UIColor.blueColor()
            self.removePostItBarButton.tintColor = UIColor.blueColor()
            self.movePostItBarButton.tintColor = UIColor.blueColor()
            self.configPostItBarButton.tintColor = UIColor.redColor()
        }
    }

    private func configurePostItBackgroundColor() {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
        //PostItのbackgroundColorを次の色へ遷移する
        var postItRawValue: Int = appDelegate.selectedPostItColor.rawValue
        if (postItRawValue == postItBackgroundColor.purple.rawValue) {
            postItRawValue = postItBackgroundColor.yellow.rawValue
        } else {
            postItRawValue += 1
        }

        //色設定
        self.colorPostItBarButton.tintColor = configureUIColor(postItRawValue)

        if (postItRawValue == postItBackgroundColor.yellow.rawValue) {
            appDelegate.selectedPostItColor = postItBackgroundColor.yellow
        } else if (postItRawValue == postItBackgroundColor.blue.rawValue) {
            appDelegate.selectedPostItColor = postItBackgroundColor.blue
        } else if (postItRawValue == postItBackgroundColor.green.rawValue) {
            appDelegate.selectedPostItColor = postItBackgroundColor.green
        } else if (postItRawValue == postItBackgroundColor.orange.rawValue) {
            appDelegate.selectedPostItColor = postItBackgroundColor.orange
        } else if (postItRawValue == postItBackgroundColor.pink.rawValue) {
            appDelegate.selectedPostItColor = postItBackgroundColor.pink
        } else if (postItRawValue == postItBackgroundColor.purple.rawValue) {
            appDelegate.selectedPostItColor = postItBackgroundColor.purple
        }
    }
    
    func configureUIColor(color: Int) -> UIColor {
        var uiColor: UIColor = UIColor.init(red: 1.0, green: 1.0, blue: 0, alpha: 1.0)
        
        if (color == postItBackgroundColor.yellow.rawValue) {
            uiColor = UIColor.init(red: 1.0, green: 1.0, blue: 0, alpha: 1.0)
        } else if (color == postItBackgroundColor.blue.rawValue) {
            uiColor = UIColor.init(red: 0.529, green: 0.809, blue: 0.98, alpha: 1.0)
        } else if (color == postItBackgroundColor.green.rawValue) {
            uiColor = UIColor.init(red: 0.678, green: 1.0, blue: 0.184, alpha: 1.0)
        } else if (color == postItBackgroundColor.orange.rawValue) {
            uiColor = UIColor.init(red: 1.0, green: 0.647, blue: 0, alpha: 1.0)
        } else if (color == postItBackgroundColor.pink.rawValue) {
            uiColor = UIColor.init(red: 1.0, green: 0.753, blue: 0.798, alpha: 1.0)
        } else if (color == postItBackgroundColor.purple.rawValue) {
            uiColor = UIColor.init(red: 0.759, green: 0.302, blue: 1.0, alpha: 1.0)
        }
        return uiColor
    }

    func configureBackgroungImg(imageNo: Int) -> UIImage {
        var uiImage: UIImage = UIImage(named: "whiteboard01.png")!
        
        if (imageNo == 0) {
            uiImage = UIImage(named: "whiteboard01.png")!
        } else if (imageNo == 1) {
            uiImage = UIImage(named: "blackboard01.png")!
        } else if (imageNo == 2) {
            uiImage = UIImage(named: "corkboard01.png")!
        } else if (imageNo == 3) {
            uiImage = UIImage(named: "gridsheet01.png")!
        }
        return uiImage
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //アプリ内課金処理 -----------------------------------
//    アイテム購入の流れ
//    
//    アプリ内課金が使えるかチェック
//    アイテム情報の取得と購入処理の開始
//    アイテム購入中の処理
//    レシートの確認とアイテムの付与
//    購入処理の終了
    
//    //アプリ内課金が使えるかチェック
//    private func checkInAppPurchaseIsAvailable() {
//        if (!SKPaymentQueue.canMakePayments()) {
//            //UIAlertController使用
//            let ac = UIAlertController(title: "エラー", message: "アプリ内課金が制限されています。", preferredStyle: .Alert)
//            let okAction = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
//                print("OK button tapped.")
//            }
//            ac.addAction(okAction)
//            presentViewController(ac, animated: true, completion: nil)
//            
//        }
//    }

    //アイテム情報を取得する。
//    private func getInAppPurchaseItemInfomation() {

//        NSSet *set = [NSSet setWithObjects:@"com.commonsense.removeads", nil];
//        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
//        productsRequest.delegate = self;
//        [productsRequest start];
//    }

    //購入処理を開始する。
    //アイテム情報の取得が完了すると呼ばれる。
//    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
//        // 無効なアイテムがないかチェック
//        if (response.invalidProductIdentifiers.count > 0) {
//            //UIAlertController使用
//            var ac = UIAlertController(title: "エラー", message: "アイテムIDが不正です。", preferredStyle: .Alert)
//            let okAction = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
//                print("OK button tapped.")
//            }
//            ac.addAction(okAction)
//            presentViewController(ac, animated: true, completion: nil)
//        }
    
        // 購入処理開始
//        [SKPaymentQueue.defaultQueue() addTransactionObserver:self];
//        for (SKProduct *product in response.products) {
//            SKPayment *payment = [SKPayment paymentWithProduct:product];
//            [[SKPaymentQueue defaultQueue] addPayment:payment];
//        }
//    }

//    //アイテム購入処理
//    //アイテム購入処理中は処理の状態が変わるごとに随時、呼ばれる。
//    //トランザクションの状態ごとに処理を分岐して状態にあった対応を行います。
//    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//        for (SKPaymentTransaction *transaction in transactions) {
//            if (transaction.transactionState == SKPaymentTransactionStatePurchasing) {
//                // 購入処理中
//                /*
//                 * 基本何もしなくてよい。処理中であることがわかるようにインジケータをだすなど。
//                 */
//                
//            } else if (transaction.transactionState == SKPaymentTransactionStatePurchased) {
//                // 購入処理成功
//                /*
//                 * ここでレシートの確認やアイテムの付与を行う。
//                 */
//                queue.finishTransaction(transaction)
//                
//            } else if (transaction.transactionState == SKPaymentTransactionStateFailed) {
//                // 購入処理エラー。ユーザが購入処理をキャンセルした場合もここにくる
//                queue.finishTransaction(transaction)
//
//                // エラーが発生したことをユーザに知らせる
//                var ac = UIAlertController(title: "エラー", message: transaction.error.localizedDescription, preferredStyle: .Alert)
//                let okAction = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
//                    print("OK button tapped.")
//                }
//                ac.addAction(okAction)
//                presentViewController(ac, animated: true, completion: nil)
//
//            } else {
//                // リストア処理完了
//                /*
//                 * アイテムの再付与を行う
//                 */
//                queue.finishTransaction(transaction)
//            }
//        }
//    }

}

