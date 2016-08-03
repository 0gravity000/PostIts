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
    dynamic var color: Int8 = 0
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

class MainViewController: UIViewController, UIScrollViewDelegate, UITextViewDelegate {
    
//    var backgroundImageView: BackGroundImageView!
    var backgroundImageView = BackGroundImageView()
    var modeFlag: Int8 = 1  //1:select, 2:add, 3: remove
    var postItColor = postItBackgroundColor.yellow
    
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
    }

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
    
    @IBAction func pushMovePostItBarButton(sender: AnyObject) {
        self.modeFlag = 4
        configureBarItemState()
    }
    
    @IBAction func pushConfigPostItBarButton(sender: AnyObject) {
        self.modeFlag = 5
        configureBarItemState()
    }
    
    // デフォルトRealmを取得
    let realm = try! Realm()
    
    enum postItBackgroundColor: Int {
        case yellow = 1
        case blue = 2
        case green = 3
        case orange = 4
        case pink = 5
        case purple = 6
    }
    
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
        self.colorPostItBarButton.tintColor = UIColor.yellowColor()
        self.showListBarButton.tintColor = UIColor.blueColor()
        
        //RealmデータからPostItsTextViewを作成 初期化
        let postIts = realm.objects(PostItsModel) // デフォルトRealmから、すべてのPostItsオブジェクトを取得
        for postIt in postIts {
            if (postIt.isVisible == true) {
                //backgroundImageView に postItsTextView を追加する
                let postItsTextView = PostItsTextView()
                addPostItsTextViewToBackgroundImageView(postItsTextView, postIts: postIt)
            }
        }
        
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
            //特に何もしない
        } else if self.modeFlag == 2 {  //2:追加モード
            //Realmデータ新規作成
            let newPostIts = PostItsModel()
            newPostIts.id = NSUUID().UUIDString
            if let realmLastObject = realm.objects(PostItsModel).last {
                newPostIts.tagNo = realmLastObject.tagNo + 1
            } else {
                newPostIts.tagNo = 0
            }
            newPostIts.color = 0
            newPostIts.creatTime = NSDate()
            newPostIts.updateTime = newPostIts.creatTime
            newPostIts.posX = Float(backgroundImageView.touchPoint.x)
            newPostIts.posY = Float(backgroundImageView.touchPoint.y)
            newPostIts.isVisible = true
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            newPostIts.content = dateFormatter.stringFromDate(newPostIts.creatTime)
            
            //Realmにデータを永続化
            //プライマリーキー id の値がすでに存在するなら、更新、存在しないなら追加
            try! realm.write {
                realm.add(newPostIts, update: true)
            }
            //Realmデータのソート tagNo 降順
            realm.objects(PostItsModel).sorted("tagNo", ascending: true)
            
            //backgroundImageView に postItsTextView を追加する
            let postItsTextView = PostItsTextView()
            addPostItsTextViewToBackgroundImageView(postItsTextView, postIts: newPostIts)
            
        } else if self.modeFlag == 3 {  //3:削除モード
            //ここでは特に何もしない
            //PostItsTextView をタッチした時に処理を行う
        } else if self.modeFlag == 4 {  //4:移動モード
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
    
    
    //テキストビューが変更された
    func textViewDidChange(textView: UITextView) {
        print("textViewDidChange : \(textView.text)")   //debug code
    }
    
    // テキストビューにフォーカスが移った
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        print("textViewShouldBeginEditing : \(textView.text)")   //debug code
        if self.modeFlag == 3 {
            //ここで、ViewとRealmデータ削除処理を行う
            //Alert表示
            let alert: UIAlertController = UIAlertController(title: "確認", message: "削除してもいいですか？", preferredStyle:  UIAlertControllerStyle.Alert)
            
            //Actionの設定
            // OKボタン
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
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
                for postIts in removePostIts {
                    try! self.realm.write {
                        self.realm.delete(postIts)
                    }
                }
                //View削除
                textView.removeFromSuperview()
                
                //全てのRealmの TagNoを振り直す
                let allPostIts = self.realm.objects(PostItsModel)
                var counter: Int16 = 0
                for postIts in allPostIts {
                    try! self.realm.write {
                        postIts.tagNo = counter
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
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
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
        } else {
            //以降テキスト編集処理を行う
            return true
        }
    }
    
    // テキストビューからフォーカスが失われた
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        print("textViewShouldEndEditing : \(textView.text)")   //debug code
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
    
    private func addPostItsTextViewToBackgroundImageView(postItsTextView: PostItsTextView, postIts:PostItsModel) {
        
        postItsTextView.delegate = self
        postItsTextView.tag = Int(postIts.tagNo)
        postItsTextView.text = postIts.tagNo.description + "\n" + postIts.content + "\n"
        postItsTextView.frame = CGRectMake(CGFloat(postIts.posX), CGFloat(postIts.posY), 100, 100);
        postItsTextView.userInteractionEnabled = true
        
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
        //PostItのbackgroundColorを次の色へ遷移する
        var postItRawValue: Int = self.postItColor.rawValue
        if (postItRawValue == postItBackgroundColor.purple.rawValue) {
            postItRawValue = postItBackgroundColor.yellow.rawValue
        } else {
            postItRawValue += 1
        }

        //色設定
        if (postItRawValue == postItBackgroundColor.yellow.rawValue) {
            self.colorPostItBarButton.tintColor = UIColor.init(red: 1.0, green: 1.0, blue: 0, alpha: 1.0)
            self.postItColor = postItBackgroundColor.yellow
        } else if (postItRawValue == postItBackgroundColor.blue.rawValue) {
            self.colorPostItBarButton.tintColor = UIColor.init(red: 0.529, green: 0.809, blue: 0.98, alpha: 1.0)
            self.postItColor = postItBackgroundColor.blue
        } else if (postItRawValue == postItBackgroundColor.green.rawValue) {
            self.colorPostItBarButton.tintColor = UIColor.init(red: 0.678, green: 1.0, blue: 0.184, alpha: 1.0)
            self.postItColor = postItBackgroundColor.green
        } else if (postItRawValue == postItBackgroundColor.orange.rawValue) {
            self.colorPostItBarButton.tintColor = UIColor.init(red: 1.0, green: 0.647, blue: 0, alpha: 1.0)
            self.postItColor = postItBackgroundColor.orange
        } else if (postItRawValue == postItBackgroundColor.pink.rawValue) {
            self.colorPostItBarButton.tintColor = UIColor.init(red: 1.0, green: 0.753, blue: 0.798, alpha: 1.0)
            self.postItColor = postItBackgroundColor.pink
        } else if (postItRawValue == postItBackgroundColor.purple.rawValue) {
            self.colorPostItBarButton.tintColor = UIColor.init(red: 0.759, green: 0.302, blue: 1.0, alpha: 1.0)
            self.postItColor = postItBackgroundColor.purple
        }
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

