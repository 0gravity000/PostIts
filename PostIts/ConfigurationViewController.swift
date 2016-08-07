//
//  ConfigurationViewController.swift
//  PostIts
//
//  Created by SASAKIAI on 2016/08/04.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//

import UIKit
import StoreKit

class ConfigurationViewController: UIViewController, UITableViewDataSource, UITextViewDelegate, PostItsPurchaseManagerDelegate {

    @IBOutlet weak var configureTableView: ConfigurationTableView!
    
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBAction func pushDoneBarButton(sender: AnyObject) {
        //画面を閉じる
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBOutlet weak var backgroundImageButton: UIButton!
    @IBAction func pushBackgroundImageButton(sender: AnyObject) {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
        if (appDelegate.selectedBackgroundImg == 3) {
            appDelegate.selectedBackgroundImg = 0
        } else {
            appDelegate.selectedBackgroundImg += 1
        }
        //backgroundImageボタンのテキストを設定
        configureBackgroundImageButtonText()
    }
    
    
    
    @IBOutlet weak var productPurchaseButton: UIButton!
    @IBAction func pushProductPurchaseButton(sender: AnyObject) {
        //UIAlertController使用
        let ac = UIAlertController(title: "確認", message: "機能制限解除キーを購入しますか？", preferredStyle: .Alert)
        //OK
        let okAction = UIAlertAction(title: "OK", style: .Default, handler:{
            // ボタンが押された時の処理
            (action: UIAlertAction!) -> Void in
            
             //アプリ内課金処理
             //プロダクトID達
             let productIdentifiers = ["jp.ne.0gravity000.PostIts.productID_LM01"]
             //        let productIdentifiers = ["productIdentifier1","productIdentifier2"]
             
             //プロダクト情報取得
             PostItsProductManager.productsWithProductIdentifiers(productIdentifiers,
             completion: { (products : [SKProduct]!, error : NSError?) -> Void in
             for product in products {
             print(product)
             //                                                                    //価格を抽出
             //                                                                    let priceString = PostItsProductManager.priceStringFromProduct(product)
             //                                                                    //価格情報を使って表示を更新したり。
             }
             })
             
             self.startPurchase("jp.ne.0gravity000.PostIts.productID_LM01")
            

            //titleを変更する
            self.productPurchaseButton.setTitle("購入済", forState: UIControlState.Normal)
        })
        
        //CANCEL
        let cancelAction = UIAlertAction(title: "CANCEL", style: .Cancel, handler:{
            // ボタンが押された時の処理
            (action: UIAlertAction!) -> Void in
            print("CANCEL button tapped.")
        })
        ac.addAction(okAction)
        ac.addAction(cancelAction)
        presentViewController(ac, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //backgroundImageボタンのテキストを設定
        configureBackgroundImageButtonText()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ConfigurationTableViewCell = tableView.dequeueReusableCellWithIdentifier("PostItsCell", forIndexPath: indexPath) as! ConfigurationTableViewCell
        return cell
    }
    
    private func configureBackgroundImageButtonText() {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
        if (appDelegate.selectedBackgroundImg == 0) {
            self.backgroundImageButton.setTitle("whiteboad", forState: UIControlState.Normal)
        } else if (appDelegate.selectedBackgroundImg == 1) {
            self.backgroundImageButton.setTitle("blackboard", forState: UIControlState.Normal)
        } else if (appDelegate.selectedBackgroundImg == 2) {
            self.backgroundImageButton.setTitle("corkboard", forState: UIControlState.Normal)
        } else if (appDelegate.selectedBackgroundImg == 3) {
            self.backgroundImageButton.setTitle("gridsheet", forState: UIControlState.Normal)
        }
    }
   
    //アプリ内課金処理 -----------------------------------
    //アプリ内課金が使えるかチェック
    func checkInAppPurchaseIsAvailable() {
        if (!SKPaymentQueue.canMakePayments()) {
            //UIAlertController使用
            let ac = UIAlertController(title: "エラー", message: "アプリ内課金が制限されています。", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
                print("OK button tapped.")
            }
            ac.addAction(okAction)
            presentViewController(ac, animated: true, completion: nil)
            
        }
    }
    
    /// 課金開始
    func startPurchase(productIdentifier : String) {
        //デリゲード設定
        PostItsPurchaseManager.sharedManager().delegate = self
        
        //プロダクト情報を取得
        PostItsProductManager.productsWithProductIdentifiers([productIdentifier], completion: { (products, error) -> Void in
            if products.count > 0 {
                //課金処理開始
                PostItsPurchaseManager.sharedManager().startWithProduct(products[0])
                
            }
        })
    }
    
    /// リストア開始
    func startRestore() {
        //デリゲード設定
        PostItsPurchaseManager.sharedManager().delegate = self
        //リストア開始
        PostItsPurchaseManager.sharedManager().startRestore()
    }
    
    
    // MARK: - PostItsPurchaseManager Delegate
    func purchaseManager(purchaseManager: PostItsPurchaseManager!, didFinishPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((complete: Bool) -> Void)!) {
        //課金終了時に呼び出される
        /*
         コンテンツ解放処理
         */
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(complete: true)
    }
    
    func purchaseManager(purchaseManager: PostItsPurchaseManager!, didFinishUntreatedPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((complete: Bool) -> Void)!) {
        //課金終了時に呼び出される(startPurchaseで指定したプロダクトID以外のものが課金された時。)
        /*
         コンテンツ解放処理
         */
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(complete: true)
    }
    
    func purchaseManager(purchaseManager: PostItsPurchaseManager!, didFailWithError error: NSError!) {
        //課金失敗時に呼び出される
        /*
         errorを使ってアラート表示
         */
    }
    
    func purchaseManagerDidFinishRestore(purchaseManager: PostItsPurchaseManager!) {
        //リストア終了時に呼び出される(個々のトランザクションは”課金終了”で処理)
        /*
         インジケータなどを表示していたら非表示に
         */
    }
    
    func purchaseManagerDidDeferred(purchaseManager: PostItsPurchaseManager!) {
        //承認待ち状態時に呼び出される(ファミリー共有)
        /*
         インジケータなどを表示していたら非表示に
         */
    }


}
