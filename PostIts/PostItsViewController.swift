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
        let cell: PostItsTableViewCell = tableView.dequeueReusableCellWithIdentifier("PostItsCell", forIndexPath: indexPath) as! PostItsTableViewCell
        print(indexPath.row)    //degug code
        //Realmデータのソート updateTime 降順 大きいものから小さいものへ ...2,1,0
        let sortedRealmObj = self.realmObj!.objects(PostItsModel).sorted("updateTime", ascending: false)

        //Realmデータの格納順にTableViewに表示する
        let postIts = sortedRealmObj
        //let postIts = self.realmObj!.objects(PostItsModel)

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        for count in indexPath.row...indexPath.row {
            cell.updatetimeLabel.text = dateFormatter.stringFromDate(postIts[count].updateTime)
            cell.contentLabel.text = postIts[count].content
            cell.contentLabel.backgroundColor = configureUIColor(postIts[count].color)
//            cell.textLabel?.text = String(postIts[count].tagNo)
//            cell.detailTextLabel?.text = String(postIts[count].content)
        }
        return cell
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

}
