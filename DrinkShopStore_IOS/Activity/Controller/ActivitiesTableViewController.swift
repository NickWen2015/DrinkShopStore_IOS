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

class ActivitiesTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    
    
    
    @IBOutlet weak var activityNameTextfield: UITextField!
    
    
    
    @IBOutlet weak var activityImage: UIImageView!
    @IBOutlet weak var activitySDateTextField: UITextField!
    
    @IBOutlet weak var activityEDateTextField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    
    
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    
    
    var activity: Activity?
    let communicator = Communicator.shared
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
        
        
        
        if let  activity = activity {
            activityNameTextfield.text = activity.activityName
            //            activitySDateTextField.text = activity.activityStartDate
            //            activityEDateTextField.text = activity.activityEndDate
            
            
        }
        updateSaveButtonState()
        
        
        startDatePicker?.datePickerMode = .date
        endDatePicker?.datePickerMode = .date
        
        startDatePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        //                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ActivitiesTableViewController.viewTapped(gestureRecognize:)))
        //
        //                view.addGestureRecognizer(tapGesture)
    }
    
    
    
    @IBAction func textFieldBeginEditing(_ sender: Any) {
        updateSaveButtonState()
    }
    
    //        @objc func viewTapped(gestureRecognize: UITapGestureRecognizer){
    //            view.endEditing(true)
    //        }
    @objc func datePickerValueChanged (datePicker: UIDatePicker) {
        
        let dateformatter = DateFormatter()
        
        dateformatter.dateFormat = "MM/dd/yyyy"
        
        
        let startDateValue = dateformatter.string(from: startDatePicker.date)
        let endDateValue = dateformatter.string(from: endDatePicker.date)
        
        activitySDateTextField.text = startDateValue
        activityEDateTextField.text = endDateValue
        view.endEditing(true)
    }
    
    
    
    func updateSaveButtonState(){
        
        let activityName = activityNameTextfield.text ?? ""
        let activitySDate = activitySDateTextField.text ?? ""
        let activityEDate = activityEDateTextField.text ?? ""
        
        let isNameExist = !activityName.isEmpty
        let isSDateExist = !activitySDate.isEmpty
        let isEDateExist = !activityEDate.isEmpty
        let shouldEnable = isNameExist && isSDateExist && isEDateExist
        saveBarButtonItem.isEnabled = shouldEnable
        
    }
    
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier == "save" else
        { return }
        
        guard  activityNameTextfield.text!.count > 0 else
        {return}
        
        let activityName = activityNameTextfield.text ?? ""
        let activitySDate = activitySDateTextField.text ?? ""
        let activityEDate = activityEDateTextField.text ?? ""
        activity = Activity(activityName: activityName, activityStartDate: activitySDate, activityEndDate: activityEDate)
    }
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
        let startDatePickerIndexPath = IndexPath(row: 1, section: 2)
        let endDatePickerIndexPath = IndexPath(row: 1, section: 3)
        
        
        if indexPath == startDatePickerIndexPath{
            
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
        return 44.0
    }
    
    //
    
    //        @IBAction func pickPictureBtnPressed(_ sender: Any) {
    //
    //            let alert = UIAlertController(title: "Please choose source:", message: nil, preferredStyle: .actionSheet)
    //            let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
    //                self.launchPicker(source: .camera)
    //            }
    //            let library = UIAlertAction(title: "Photo library", style: .default) { (action) in
    //                self.launchPicker(source: .photoLibrary)
    //            }
    //            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
    //            alert.addAction(camera)
    //            alert.addAction(library)
    //            alert.addAction(cancel)
    //            present(alert, animated: true)
    //    }
    //    func launchPicker(source: UIImagePickerController.SourceType) {
    //
    //        //Check if the source is valid or not?
    //        guard UIImagePickerController.isSourceTypeAvailable(source)
    //            else {
    //                print("Invalid source type")
    //                return
    //        }
    //
    //        let picker = UIImagePickerController()
    //        picker.delegate = self
    //        //        picker.mediaTypes = ["public.image", "public.movie"]
    //        picker.mediaTypes = [kUTTypeImage] as [String]
    //        picker.sourceType = source
    //
    //
    //        present(picker, animated: true)
    //    }
    //UIImage最好不要存在手機記憶體,如果必要記得壓縮,png是無損,所以檔案會比jpg大。選jpg可以減輕server負擔。
    //MARK: - UIImagePickerControllerDelegate protocol Method.
    //    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    //        print("info: \(info)")
    //        guard let type = info[.mediaType] as? String  else {
    //            assertionFailure("Invalid type")
    //            return
    //        }
    //        if type == kUTTypeImage as String {
    //            guard let originalImage = info[.originalImage] as? UIImage else {
    //                assertionFailure("originalImage is nil.")
    //                return
    //            }
    //            let resizedImage = originalImage.resize(maxEdge: 1024)!
    //            let jpgData = resizedImage.jpegData(compressionQuality: 0.8)//壓縮率:0.0~1之間,為了品質一般都控制在0.7~0.8
    //            //            let pngData = resizedImage.pngData()
    //            print("jpgData: \(jpgData!.count)")
    //            print("pngData: \(pngData!.count)")
    //            communicator.send(photo: jpgData!) { (result, error)
    //                in
    //                if let error = error {
    //                    print("Upload photo fail: \(error)")
    //                    return
    //                }
    //                self.doRefreshJob()
    //            }
    //        } else if type == kUTTypeMovie as String {
    //            //...
}
//        picker.dismiss(animated: true) //Important! 加這行picker才會把自己收起來




