//
//  ConfigurationTableViewController.swift
//  PostIts
//
//  Created by SASAKIAI on 2016/08/07.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//

import UIKit
import StoreKit

class ConfigurationTableViewController: UITableViewController, PostItsPurchaseManagerDelegate {

    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBAction func pushDoneBarButton(sender: AnyObject) {
        //画面を閉じる
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var backgroundImageLabel: UILabel!
    @IBOutlet weak var numberOfPostItsLabel: UILabel!
    
    @IBOutlet weak var productPurchaseButton: UIButton!
    @IBAction func pushProductPurchaseButton(sender: AnyObject) {
        //制限解除キーを購入
        let ac = UIAlertController(title: NSLocalizedString("alertTitle_A001", comment: ""),
                                   message: NSLocalizedString("alertMessage_A003", comment: ""),
                                   preferredStyle: .Alert)
        //OK
        let okAction = UIAlertAction(title: NSLocalizedString("alertTitle_A002", comment: ""),
                                     style: .Default,
                                     handler:{
            // ボタンが押された時の処理
            (action: UIAlertAction!) -> Void in
            
            //アプリ内課金処理
            //2重処理してる???のでこっちは削除
//            //プロダクトID達
//            let productIdentifiers = ["jp.ne.0gravity000.PostIts.productID_LM01"]
//            //        let productIdentifiers = ["productIdentifier1","productIdentifier2"]
//            
//            //プロダクト情報取得
//            PostItsProductManager.productsWithProductIdentifiers(productIdentifiers,
//                completion: { (products : [SKProduct]!, error : NSError?) -> Void in
//                    for product in products {
//                        print(product)
////                        //価格を抽出
////                        let priceString = PostItsProductManager.priceStringFromProduct(product)
////                        //価格情報を使って表示を更新したり。
//                    }
//            })
            
            //プロダクト情報取得
            self.startPurchase("jp.ne.0gravity000.PostIts.productID_LRK01")
//            self.startPurchase("jp.ne.0gravity000.PostIts.productID_LM99")  //debug code error用
            
            //ButtonTitleの変更 ここではダメ
            //purchaseManager didFinishPurchaseWithTransaction で実行する
        })
        
        //CANCEL
        let cancelAction = UIAlertAction(title: NSLocalizedString("alertTitle_A003", comment: ""),
                                         style: .Cancel,
                                         handler:{
            // ボタンが押された時の処理
            (action: UIAlertAction!) -> Void in
            print("CANCEL button tapped.")
        })
        ac.addAction(okAction)
        ac.addAction(cancelAction)
        presentViewController(ac, animated: true, completion: nil)
    }
    
    @IBOutlet weak var restoreProductButton: UIButton!
    
    @IBAction func pushRestoreProductButton(sender: AnyObject) {
        //リストア処理 ここでするのはいいか???
        self.startRestore()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        //backgroundImageラベルのテキストを設定
        configureBackgroundImageLabelText()
        //制限解除キーの状態をチェックし、表示を変える
        //このタイミングでNSUserdefaultsを使ってデータを保存する
        checkLimitationReleaseKeyStatus()
    }
    
    private func configureBackgroundImageLabelText() {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
        if (appDelegate.selectedBackgroundImg == 0) {
            self.backgroundImageLabel.text = NSLocalizedString("backgroundImg_whiteboard", comment: "")
        } else if (appDelegate.selectedBackgroundImg == 1) {
            self.backgroundImageLabel.text = NSLocalizedString("backgroundImg_blackboard", comment: "")
        } else if (appDelegate.selectedBackgroundImg == 2) {
            self.backgroundImageLabel.text = NSLocalizedString("backgroundImg_corkboard", comment: "")
        } else if (appDelegate.selectedBackgroundImg == 3) {
            self.backgroundImageLabel.text = NSLocalizedString("backgroundImg_gridsheet", comment: "")
        }
    }
    
    //制限解除キーの状態をチェックし、表示を変える
    //このタイミングでNSUserdefaultsを使ってデータを保存する
    private func checkLimitationReleaseKeyStatus() {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
        if (appDelegate.isPurchasedLimitationReleaseKey == true) {
            self.productPurchaseButton.setTitle(NSLocalizedString("buttonTitle_A001", comment: ""),
                                                forState: UIControlState.Normal)
            self.productPurchaseButton.enabled = false
            self.numberOfPostItsLabel.text = (NSLocalizedString("labelText_A001", comment: ""))
        } else {
            self.productPurchaseButton.setTitle(NSLocalizedString("buttonTitle_A002", comment: ""),
                                                forState: UIControlState.Normal)
            self.productPurchaseButton.enabled = true
            self.numberOfPostItsLabel.text = ("10")
        }

        //このタイミングでNSUserdefaultsを使ってデータを保存する
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(appDelegate.isPurchasedLimitationReleaseKey, forKey: "isPurchasedLimitationReleaseKey")

    }

    
//     MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else if section == 2 {
            return 1
        } else if section == 3 {
            return 2
        } else {
            //ありえない
            return 1
        }
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //アプリ内課金処理 -----------------------------------
    /// 課金開始
    func startPurchase(productIdentifier : String) {
        //デリゲード設定
        PostItsPurchaseManager.sharedManager().delegate = self
        
        //プロダクト情報を取得
        PostItsProductManager.productsWithProductIdentifiers([productIdentifier], completion: { (products, error) -> Void in
            print("プロダクト取得: \(products), \(error?.localizedDescription)") //debug code
            if products.count > 0 {
                //課金処理開始
                PostItsPurchaseManager.sharedManager().startWithProduct(products[0])
                
            } else {
                //プロダクト取得失敗
                self.productManagerDidFailWithError(error!) //これ大丈夫か???
                //print("プロダクト取得失敗: \(products), \(error?.localizedDescription)")
            }
        })
    }
    
    /// リストア開始
    func startRestore() {
        //デリゲード設定
        PostItsPurchaseManager.sharedManager().delegate = self

        //制限解除フラグを落とす
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
        appDelegate.isPurchasedLimitationReleaseKey = false
        //リストア開始
        PostItsPurchaseManager.sharedManager().startRestore()
    }
    
    // MARK: - PostItsPurchaseManager Delegate
    func purchaseManager(purchaseManager: PostItsPurchaseManager!, didFinishPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((complete: Bool) -> Void)!) {
        //課金終了、リストア時に呼び出される
        /*
         コンテンツ解放処理
         */
        //制限解除フラグを立てる
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
        appDelegate.isPurchasedLimitationReleaseKey = true
        //制限解除キーの状態をチェックし、表示を変える
        //このタイミングでNSUserdefaultsを使ってデータを保存する
        checkLimitationReleaseKeyStatus()
        
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
        print("purchaseManager didFailWithError = \(error)")
        let ac = UIAlertController(title: NSLocalizedString("alertTitle_A004", comment: ""),
                                   message: error.localizedDescription,
                                   preferredStyle: .Alert)
        //OK
        let okAction = UIAlertAction(title: NSLocalizedString("alertTitle_A002", comment: ""),
                                     style: .Default,
                                     handler:{
            // ボタンが押された時の処理
            (action: UIAlertAction!) -> Void in
        })
        ac.addAction(okAction)
        presentViewController(ac, animated: true, completion: nil)
    }
    
    //同様にProductManager版もいる???
    func productManagerDidFailWithError(error: NSError!) {
        /*
         errorを使ってアラート表示
         */
        //プロダクト取得失敗
        print("productManager didFailWithError = \(error)")
        let ac = UIAlertController(title: NSLocalizedString("alertTitle_A004", comment: ""),
                                   message: error.localizedDescription,
                                   preferredStyle: .Alert)
        //OK
        let okAction = UIAlertAction(title: NSLocalizedString("alertTitle_A002", comment: ""),
                                     style: .Default,
                                     handler:{
            // ボタンが押された時の処理
            (action: UIAlertAction!) -> Void in
        })
        ac.addAction(okAction)
        presentViewController(ac, animated: true, completion: nil)
    }
    
    
    func purchaseManagerDidFinishRestore(purchaseManager: PostItsPurchaseManager!) {
        //リストア終了時に呼び出される(個々のトランザクションは”課金終了”で処理)
        /*
         インジケータなどを表示していたら非表示に
         なお、プロダクト未購入時は、
         purchaseManager didFinishPurchaseWithTransaction が呼ばれず、ここに来るので注意
         */
        //制限解除キーの状態をチェックし、表示を変える
        //このタイミングでNSUserdefaultsを使ってデータを保存する
        checkLimitationReleaseKeyStatus()
        
        let ac = UIAlertController(title: NSLocalizedString("alertTitle_A001", comment: ""),
                                   message: NSLocalizedString("alertMessage_A004", comment: ""),
                                   preferredStyle: .Alert)
        //OK
        let okAction = UIAlertAction(title: NSLocalizedString("alertTitle_A002", comment: ""),
                                     style: .Default,
                                     handler:{
            // ボタンが押された時の処理
            (action: UIAlertAction!) -> Void in
        })
        ac.addAction(okAction)
        presentViewController(ac, animated: true, completion: nil)

        print("purchaseManagerDidFinishRestore")    //debug code
    }
    
    func purchaseManagerDidDeferred(purchaseManager: PostItsPurchaseManager!) {
        //承認待ち状態時に呼び出される(ファミリー共有)
        /*
         インジケータなどを表示していたら非表示に
         */
        print("purchaseManagerDidDeferred")
    }
    
}
