//
//  ActivitiesViewController.swift
//  DrinkShopStore_IOS
//
//  Created by 周芳如 on 2018/11/3.
//  Copyright © 2018 Nick Wen. All rights reserved.
//

import UIKit

class ActivitiesListTableViewController: UITableViewController {
    
    
    var newsArray = [NewsItem]()
    var newsNameArray = [String]()
    var newsSDateArray = [String]()
    var newsEDateArray = [String]()
    var newsIdArray = [Int]()
    var imageArray = [Data]()
  
    
    var newsItem: NewsItem?
    var id_value = 0
    var name_value = ""
    var sDate_value = ""
    var eDate_value = ""
  
    
    
    let communicator = Communicator.shared
    let PHOTO_URL = Common.SERVER_URL + "NewsServlet"
    
    
    @IBOutlet var newsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
          newsArray = [NewsItem]()
        //啟用 navigation 導覽列上的編輯 tableView 鈕
        navigationItem.leftBarButtonItem = editButtonItem
        
        //取得最新消息資訊（文字部分）
        Communicator.shared.retriveNewsInfo{ (result, error) in
            if let error = error {
                print(" Load Data Error: \(error)")
                return
            }
            guard let result = result else {
                print (" result is nil")
                return
            }
            print("Load Data OK.")
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) else {
                print(" Fail to generate jsonData.")
                
                return
            }
            //解碼
            let decoder = JSONDecoder()
            guard let resultObject = try? decoder.decode([NewsItem].self, from: jsonData) else {
                print(" Fail to decode jsonData.")
                return
            }
            for newsItem in resultObject {
                self.newsArray.append(newsItem)
                
                let newsName = newsItem.name
                self.newsNameArray.append(newsName)
            }
            for newsItem in resultObject {
                let newsSDate = newsItem.sDate
                
                self.newsSDateArray.append(newsSDate)
                
            }
            
            for newsItem in resultObject {
                let newsEDate = newsItem.eDate
                
                self.newsEDateArray.append(newsEDate)
              
            }

            for newsItem in resultObject {
                let newsId = newsItem.id
                
                self.newsIdArray.append(newsId)
            }
            DispatchQueue.main.async {
                self.newsTableView.reloadData()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        newsIdArray.removeAll()
   

    }
    
    @IBAction func goBackFromAddNews(segue: UIStoryboardSegue) {
        
        self.viewDidLoad()
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //取得總共幾列
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  newsIdArray.count
    }
    
    //dataSource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ActivitiesTableViewCell
    
        let id = newsIdArray[indexPath.row]
        cell.activityImage.image = UIImage(named: "img_product_drink_shop")
        Communicator.shared.getPhotoById(photoURL: self.PHOTO_URL, id: id) { (result, error) in
            
            guard let data = result else {
                return
            }
            
            if let currentIndexPath = tableView.indexPath(for: cell), currentIndexPath == indexPath {
                DispatchQueue.main.async {
                    
                    cell.activityImage.image = UIImage(data: data)
                    
                    let name = self.newsArray[indexPath.row].name
                    
                    cell.activityNameLabel.text = name
                    cell.activitySDateLabel.text = self.newsArray[indexPath.row].sDate
                    cell.activityEDateLabel.text = self.newsArray[indexPath.row].eDate
                    
                }
                
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
        
    }
    
    
    @IBAction func unwindToList(_ segue: UIStoryboardSegue) {
    }
  
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //Delete the row from the data source
            let id = newsIdArray[indexPath.row]
            newsIdArray.remove(at: indexPath.row) //先砍資料再砍畫面
            
            let activityName = newsNameArray[indexPath.row]
            let activitySDate = newsSDateArray[indexPath.row]
            let activityEDate = newsEDateArray[indexPath.row]
            let newsItem = NewsItem(id: id, name: activityName, sDate: activitySDate, eDate: activityEDate)
            
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            guard let newsData = try? encoder.encode(newsItem) else {
                assertionFailure("Cast news to json is Fail.")
                return
            }
            
            print(String(data: newsData, encoding: .utf8)!)
            
            guard let newsString = String(data: newsData, encoding: .utf8) else {
                assertionFailure("Cast newsData to String is Fail.")
                return
            }
            
            //寫入資料庫
            communicator.newsDelete(news:newsString, id: id) { (result, error) in
                if let error = error {
                    print("Delete news fail: \(error)")
                    return
                }
                
                guard let updateStatus = result as? Int else {
                    assertionFailure("modify fail.")
                    return
                }
                
                if updateStatus == 1 {
                    //跳出成功視窗
                    let alertController = UIAlertController(title: "完成", message:
                        "刪除成功", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "確定", style: .default,handler: nil))
                    self.present(alertController, animated: false, completion: nil)
                    
                } else {
                    let alertController = UIAlertController(title: "失敗", message:
                        "刪除失敗", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "確定", style: .default,handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }else if editingStyle == .insert {
            //             Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "update" {
            // 看看使用者選到了哪一個 indexPath
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                
                let newsItem = newsArray[selectedIndexPath.row]
                
                
                // 取得下一頁
                let  destination = segue.destination as! UINavigationController
                
                let activityTableVC = destination.topViewController as! ActivitiesTableViewController
                
                activityTableVC.newsItem = newsItem
               
         
               let id = newsItem.id
                Communicator.shared.getPhotoById(photoURL: self.PHOTO_URL, id: id) { (result, error) in
                    
                    guard let data = result else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        activityTableVC.activityImage.image = UIImage(data: data)
                    }
                }
            }
        }
        
    }
}
