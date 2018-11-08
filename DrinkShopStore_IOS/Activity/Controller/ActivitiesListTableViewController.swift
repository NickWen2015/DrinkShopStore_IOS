//
//  ActivitiesViewController.swift
//  DrinkShopStore_IOS
//
//  Created by 周芳如 on 2018/11/3.
//  Copyright © 2018 Nick Wen. All rights reserved.
//

import UIKit

class ActivitiesListTableViewController: UITableViewController {

    
    //繼承UITableViewController 已包含protocol & 下列兩行任務
    //tableView.delegate = self
    //tableView.datasource = self
    
    var activities = [Activity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        //啟用 navigation 導覽列上的編輯 tableView 鈕
        navigationItem.leftBarButtonItem = editButtonItem
        

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //註冊通知
        
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func save(){
        Activity.save(activities)
    }
    
    // MARK: - Table view data source
    
    
    
    //取得總共幾列
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return  activities.count
        
        
    }
    
    //dataSource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ActivitiesTableViewCell
  
    // 取得 activity
     



//        let activity = activities[indexPath.row] //第幾列
//        cell.activity = activity
        
        return cell
  
        
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
      
    }
    
    
    
    @IBAction func unwindToList(_ segue: UIStoryboardSegue) {
        
        guard segue.identifier == "save" else
        {return}
        
        // 新增
    
        let source = segue.source as!
        ActivitiesTableViewController
        if let activity = source.activity {
            //判斷使用者有沒有點選其中某列
            if let selectedIndexPath =
                tableView.indexPathForSelectedRow{
                //修改
                activities[selectedIndexPath.row] = activity
                //重新整理該 indexpath畫面
                tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
                //tableView.reloadData 可以全部重新載入,但是效能沒那麼好,但是資料如果是從網路下取下來的話,會造成資料全部重新從網路重載,效能會不好
            }else{
                
             
                //準備一個新的 indexPath
                let indexPath = IndexPath(row: activities.count, section: 0)
             
               activities.append(activity)
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        }
    
   
        
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //             Delete the row from the data source
            activities.remove(at: indexPath.row) //先砍資料再砍畫面
            tableView.deleteRows(at: [indexPath], with: .fade)
        }else if editingStyle == .insert {
            //             Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 看看使用者選到了哪一個 indexPath
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
      
            let activity = activities[selectedIndexPath.row]
            //取得下一頁
            let destination = segue.destination as!
            UINavigationController
            let activityTableVC = destination.topViewController as! ActivitiesTableViewController
         
          activityTableVC.activity = activity
          
            
            
        }
        
    }
    
    
}
