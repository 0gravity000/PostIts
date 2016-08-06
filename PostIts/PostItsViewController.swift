//
//  PostItsViewController.swift
//  PostIts
//
//  Created by SASAKIAI on 2016/07/28.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//

import UIKit
import RealmSwift

class PostItsViewController: UIViewController, UITableViewDataSource, UITextViewDelegate {

    var realmObj: Realm? = nil
   // var sortedRealmObj: Results<PostItsModel>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let postIts = self.realmObj!.objects(PostItsModel) // デフォルトRealmから、すべてのPostItsオブジェクトを取得
        return postIts.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostItsCell", forIndexPath: indexPath)
        print(indexPath.row)    //degug code
        //Realmデータのソート updateTime 降順 大きいものから小さいものへ ...2,1,0
        let sortedRealmObj = self.realmObj!.objects(PostItsModel).sorted("updateTime", ascending: false)

        //Realmデータの格納順にTableViewに表示する
        let postIts = sortedRealmObj
        //let postIts = self.realmObj!.objects(PostItsModel)
        for count in indexPath.row...indexPath.row {
            cell.textLabel?.text = String(postIts[count].tagNo)
            cell.detailTextLabel?.text = String(postIts[count].content)
        }
// Old01
//        let postIts = self.realmObj!.objects(PostItsModel).filter("tagNo == \(indexPath.row)")
//        for postIt in postIts {
//            cell.textLabel?.text = String(postIt.tagNo)
//            cell.detailTextLabel?.text = String(postIt.content)
//            //複数存在したらループを抜ける
//            break
//        }
        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
