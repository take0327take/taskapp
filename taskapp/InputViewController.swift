//
//  InputViewController.swift
//  taskapp
//
//  Created by TakeshiTakeuchi on 2016/09/04.
//  Copyright © 2016年 jp.techacademy.takeshi.takeuchi. All rights reserved.
//

import UIKit
import RealmSwift

class InputViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var category: UITextField!
    
    let realm = try! Realm()
    var task:Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        
        // categoryを追加
        category.text = task.category

        // タイトルのフレームワーク設定
        titleTextField.layer.borderWidth = 0.5
        titleTextField.layer.cornerRadius = 3

        // 内容のフレームワーク設定
        contentsTextView.layer.borderWidth = 0.5
        contentsTextView.layer.cornerRadius = 3
        contentsTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        // 分類のフレームワーク設定
        category.layer.borderWidth = 0.5
        category.layer.cornerRadius = 3
        category.layer.borderColor = UIColor.lightGrayColor().CGColor
        
    }

//    /*
//     テキストが編集された際に呼ばれる.
//     */
//    func textField(textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        
//        // 文字数最大を決める.
//        let minLength: Int = 6
//        
//        // 入力済みの文字と入力された文字を合わせて取得.
//        let str = textField.text! + string
//        
//        // 文字数がmaxLength以下ならtrueを返す.
//        if str.characters.count > minLength {
//            return true
//        }
//        print("何か入力してください")
//        return false
//    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }

    override func viewWillDisappear(animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            //categoryを追加
            self.task.category = self.category.text!
            self.realm.add(self.task, update: true)
        }
        
        super.viewWillDisappear(animated)
    }
    
    // タスクのローカル通知を設定する
    func setNotification(task: Task) {
        
        // すでに同じタスクが登録されていたらキャンセルする
        for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
            if notification.userInfo!["id"] as! Int == task.id {
                UIApplication.sharedApplication().cancelLocalNotification(notification)
                break   // breakに来るとforループから抜け出せる
            }
        }
        
        let notification = UILocalNotification()
        
        notification.fireDate = task.date
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.alertBody = "\(task.title)"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["id":task.id]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
    }
    
        
}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


