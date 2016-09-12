//
//  ViewController.swift
//  taskapp
//
//  Created by TakeshiTakeuchi on 2016/09/04.
//  Copyright © 2016年 jp.techacademy.takeshi.takeuchi. All rights reserved.
//

import UIKit
import RealmSwift


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categorySerchBar: UISearchBar!
    
    // Realmインスタンスを取得
    let realm = try! Realm()
    
    // DBにタスクがセットされるリスト。
    // 日付の近い順でソート・降順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task).sorted("date",ascending: false)
    
    // 検索結果配列
    var searchResult = try! Realm().objects(Task)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        // delegateを自分のものに
        categorySerchBar.delegate = self
        
        // 初期表示文言
        categorySerchBar.placeholder = "カテゴリーを入力してください"
        
        // Returnキーを押せるようにする。
        categorySerchBar.enablesReturnKeyAutomatically = false
        
        // 検索結果配列にデータをコピーする。
        searchResult = taskArray
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     * データ数=セル数を返す変数
     */
    func tableView(tableView: UITableView, numberOfRowsInSection selection: Int) -> Int {
        return taskArray.count
    }
    
    /**
     * 各セルの内容を返す変数
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 再利用可能なセルを設定
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell",forIndexPath: indexPath)
        
        // Cell に値を入力する。
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title + "("+task.category + ")"
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.stringFromDate(task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    // MARK: UITableViewDeleteプロトコルのメソッド
    
    /**
     * 各セルを選択した際に実行されるメソッド
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("cellSegue", sender: nil)
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        categorySerchBar.endEditing(true)
        
        if (categorySerchBar.text == "") {
            // 空の場合はすべて表示
            taskArray = try! Realm().objects(Task).sorted("date",ascending: false)
            tableView.reloadData()
            
        } else {
            taskArray = try! Realm().objects(Task).filter("category = '\(categorySerchBar.text!)'")
            tableView.reloadData()
            
        }
    }
    
    /**
     * セルが削除が可能なことを伝えるメソッド
     */
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath:NSIndexPath) ->
        UITableViewCellEditingStyle {
            return UITableViewCellEditingStyle.Delete
    }
    
    /**
     * Deleteボタンが押された時に処理されるメソッド
     */
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle,
                   forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            // ローカル通知をキャンセルする
            let task = taskArray[indexPath.row]
            
            for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
                if notification.userInfo!["id"] as! Int == task.id {
                    UIApplication.sharedApplication().cancelLocalNotification(
                        notification
                    )
                    break
                }
            }
            
            //データベースから削除する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRowsAtIndexPaths(
                    [indexPath],
                    withRowAnimation: UITableViewRowAnimation.Fade
                )
                
            }
        }
    }
    
    
    
    // MARK: - Segue
    
    /**
     * segue で画面遷移するに呼ばれる
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        let inputViewController:InputViewController =
            segue.destinationViewController as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0 {
                task.id = taskArray.max("id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
    /**
     * 入力画面から戻ってきた時に TableView を更新させる
     */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}