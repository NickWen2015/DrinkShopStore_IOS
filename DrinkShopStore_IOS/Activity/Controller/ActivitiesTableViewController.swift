//
//  ActivitiesTableViewController.swift
//  DrinkShopStore_IOS
//
//  Created by 周芳如 on 2018/11/3.
//  Copyright © 2018 Nick Wen. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

class ActivitiesTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate  {
    
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var activityNameTextfield: UITextField!
    @IBOutlet weak var activityImage: UIImageView!
    @IBOutlet weak var activitySDateLabel: UILabel!
    @IBOutlet weak var activityEDateLabel: UILabel!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    var newsItem: NewsItem?
    var id_value = 0
    var name_value = ""
    var sDate_value = ""
    var eDate_value = ""
    var newsId:Int = 0
    var status: Int = 1
    
    let communicator = Communicator.shared
    let PHOTO_URL = Common.SERVER_URL + "NewsServlet"
    
    //IndexPath
    let startDateTitle = IndexPath(row: 0, section: 2)
    let endDateTitle = IndexPath(row: 0, section: 3)
    
    
    //控制項
    var startDateShown = false {
        didSet{
            startDatePicker.isHidden = !startDateShown
        }
    }
    var endDateShown = false {
        didSet{
            endDatePicker.isHidden = !endDateShown
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let updateNewsItem = newsItem {
            newsId = updateNewsItem.id
            activityNameTextfield.text = updateNewsItem.name
            activitySDateLabel.text = updateNewsItem.sDate
            activityEDateLabel.text = updateNewsItem.eDate
            
        }
        
        updateSaveButtonState()
        
        
        startDatePicker?.datePickerMode = .date
        endDatePicker?.datePickerMode = .date
        
        startDatePicker.minimumDate = Calendar.current.date(byAdding:. day, value: 0, to: Date())
        
        
        startDatePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        
    }
    
    @IBAction private func textFieldBeginEditing(_ sender: Any) {
        updateSaveButtonState()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @objc func datePickerValueChanged (datePicker: UIDatePicker) {
        
        let dateformatter = DateFormatter()
        
        //自定義日期格式
        dateformatter.dateFormat = "yyyy-MM-dd"
        
        
        let startDateValue = dateformatter.string(from: startDatePicker.date)
        let endDateValue = dateformatter.string(from: endDatePicker.date)
        
        endDatePicker.minimumDate = Calendar.current.date(byAdding: .day, value: 0, to: startDatePicker.date)
        
        
        if startDateShown == true {
            activitySDateLabel.text = startDateValue
            activitySDateLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            
        } else {
            activityEDateLabel.text = endDateValue
            activityEDateLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            view.endEditing(true)
        }
    }
    
    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath{
        case startDateTitle:
            tableView.beginUpdates()
            if endDateShown && !startDateShown{
                endDateShown = false
            }
            startDateShown = !startDateShown
            tableView.endUpdates()
        case endDateTitle:
            tableView.beginUpdates()
            if startDateShown && !endDateShown{
                startDateShown = false
            }
            endDateShown = !endDateShown
            tableView.endUpdates()
        default:
            break
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 針對開始日期的調整
        let activityImageIndexPath = IndexPath(row: 0, section: 0)
        let startDatePickerIndexPath = IndexPath(row: 1, section: 2)
        let endDatePickerIndexPath = IndexPath(row: 1, section: 3)
        
        if indexPath == activityImageIndexPath{
            return 90.0
        }
        else if indexPath == startDatePickerIndexPath{
            
            if startDateShown{
                
                return 216.0
            }else{
                return 0.0
            }
            
        } else if indexPath == endDatePickerIndexPath{
            
            if endDateShown{
                
                return 216.0
            }else{
                return 0.0
            }
        }
        return  44.0
    }
    
    
    @IBAction func pickPictureBtnPressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Please choose source:", message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.launchPicker(source: .camera)
        }
        let library = UIAlertAction(title: "Photo library", style: .default) { (action) in
            self.launchPicker(source: .photoLibrary)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(camera)
        alert.addAction(library)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    func launchPicker(source: UIImagePickerController.SourceType) {
        
        //Check if the source is valid or not?
        guard UIImagePickerController.isSourceTypeAvailable(source)
            else {
                print("Invalid source type")
                return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.mediaTypes = [kUTTypeImage] as [String]
        picker.sourceType = source
        
        
        present(picker, animated: true)
    }
    
    
    //MARK: - UIImagePickerControllerDelegate protocol Method.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("info: \(info)")
        guard let type = info[.mediaType] as? String  else {
            assertionFailure("Invalid type")
            return
        }
        if type == kUTTypeImage as String {
            guard let originalImage = info[.originalImage] as? UIImage else {
                assertionFailure("originalImage is nil.")
                return
            }
            let resizedImage = originalImage.resize(maxEdge: 1024)!
            let jpgData = resizedImage.jpegData(compressionQuality: 0.8)//壓縮率:0.0~1之間,為了品質一般都控制在0.7~0.8
            
            let pngData = resizedImage.pngData()
            print("jpgData: \(jpgData!.count)")
            print("pngData: \(pngData!.count)")
            
            
            activityImage.image = resizedImage
            
            picker.dismiss(animated: true) //Important! 加這行picker才會把自己收起來
        }
    }
    
    func updateSaveButtonState(){
        
        let activityName = activityNameTextfield.text ?? ""
        let activitySDate = activitySDateLabel.text ?? ""
        let activityEDate = activityEDateLabel.text ?? ""
        let activityImage = self.activityImage.image
        
        let isNameExist = !activityName.isEmpty
        let isSDateExist = !activitySDate.isEmpty
        let isEDateExist = !activityEDate.isEmpty
        let isImageExist = !(activityImage?.isEqual(nil))!
        let shouldEnable = isNameExist && isSDateExist && isEDateExist && isImageExist
        saveBarButtonItem.isEnabled = shouldEnable
    }
    
    func convertImageToBase64(image: UIImage) -> String {
        let imageData = image.pngData()!
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    @IBAction func saveBtnPressed(_ sender: UIBarButtonItem) {
        
        guard let selectedImage = activityImage.image else {
            print("Image not found!")
            return
        }
        
        let imageBase64 =  convertImageToBase64(image: selectedImage)
        let activityName = activityNameTextfield.text!
        let activitySDate = activitySDateLabel.text!
        let activityEDate = activityEDateLabel.text!
        
        
        let newsItem = NewsItem(id: id_value, name: activityName, sDate: activitySDate, eDate: activityEDate)
        
        
        if self.newsItem != nil {
            let id = self.newsItem?.id
            
            let updateNewsItem = NewsItem(id: id!, name: activityName, sDate: activitySDate, eDate: activityEDate)
            
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            guard let newsData = try? encoder.encode(updateNewsItem) else {
                assertionFailure("Cast news to json is Fail.")
                return
            }
            
            print(String(data: newsData, encoding: .utf8)!)
            
            guard let newsString = String(data: newsData, encoding: .utf8) else {
                assertionFailure("Cast newsData to String is Fail.")
                return
            }
            //寫入資料庫
            communicator.newsUpdate(news: newsString, photo: imageBase64) { (result, error) in
                if let error = error {
                    print("Update news fail: \(error)")
                    return
                }
                
                guard let updateStatus = result as? Int else {
                    assertionFailure("modify fail.")
                    return
                }
                
                if updateStatus == 1 {
                    //跳出成功視窗
                    let alertController = UIAlertController(title: "完成", message:
                        "儲存成功", preferredStyle: .alert)
                    let okBtn = UIAlertAction(title: "確認", style: .default,handler: { _ in
                        let VC = self.storyboard?.instantiateViewController(withIdentifier: "newsList") as! ActivitiesListTableViewController
                        self.present(VC, animated: true, completion: nil)
                    })
                    alertController.addAction(okBtn)
                    self.present(alertController, animated: true)
                    //儲存按鈕消失
                    self.saveBarButtonItem.isEnabled = false
                    
                } else {
                    let alertController = UIAlertController(title: "失敗", message:
                        "儲存失敗", preferredStyle: .alert)
                    let okBtn = UIAlertAction(title: "確認", style: .default)
                    alertController.addAction(okBtn)
                    self.present(alertController, animated: true)
                }
            }
            
        } else {
            
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
            communicator.newsInsert(news: newsString, photo: imageBase64) { (result, error) in
                if let error = error {
                    print("Insert news fail: \(error)")
                    return
                }
                
                guard let InsertStatus = result as? Int else {
                    assertionFailure("modify fail.")
                    return
                }
                
                if InsertStatus == 1 {
                    //跳出成功視窗
                    let alertController = UIAlertController(title: "完成", message:
                        "儲存成功", preferredStyle: .alert)
                    let okBtn = UIAlertAction(title: "確認", style: .default,handler: { _ in
                        let VC = self.storyboard?.instantiateViewController(withIdentifier: "newsList") as! ActivitiesListTableViewController
                        self.present(VC, animated: true, completion: nil)
                    })
                    alertController.addAction(okBtn)
                    self.present(alertController, animated: true)
                    //儲存按鈕消失
                    self.saveBarButtonItem.isEnabled = false
                    
                } else {
                    let alertController = UIAlertController(title: "失敗", message:
                        "儲存失敗", preferredStyle: .alert)
                    let okBtn = UIAlertAction(title: "確認", style: .default)
                    alertController.addAction(okBtn)
                    self.present(alertController, animated: true)
                }
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier == "save" else
        { return }
        
        guard  activityNameTextfield.text!.count > 0 else
        {return}
        
        let newsName = activityNameTextfield.text ?? ""
        let sDate = activitySDateLabel.text ?? ""
        let eDate = activityEDateLabel.text ?? ""
        newsItem = NewsItem(id: id_value, name: newsName, sDate: sDate, eDate: eDate)
    }
    
    
}
