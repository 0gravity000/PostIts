//
//  SelectBackgroundImageViewController.swift
//  PostIts
//
//  Created by SASAKIAI on 2016/08/07.
//  Copyright © 2016年 SASAKIAI. All rights reserved.
//

import UIKit

class SelectBackgroundImageViewController: UIViewController {

    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBAction func pushDoneBarButton(sender: AnyObject) {
        //画面を閉じる
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBOutlet weak var backgroundImgPicker: UIPickerView!
    
    var backgroundImgArray: NSArray = ["whiteboard","blackboard","corkboard","gridsheet"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
        backgroundImgPicker.selectRow(appDelegate.selectedBackgroundImg, inComponent: 0, animated: false)
    }
    
    //表示列
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //表示個数
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return backgroundImgArray.count
    }
    
    //表示内容
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String {
        return backgroundImgArray[row] as! String
    }
    
    //選択時
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("列: \(row)")  //debug code
        print("値: \(backgroundImgArray[row])")  //debug code
        
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
        appDelegate.selectedBackgroundImg = row
        
    }

}
