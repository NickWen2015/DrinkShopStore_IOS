//
//  ViewController.swift
//  HelloMyPushMessage
//
//  Created by Nick Wen on 2018/10/24.
//  Copyright © 2018 Nick Wen. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

class OrderOnlineViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var chatView: ChatView!
    @IBOutlet weak var sendMsgBtn: UIButton!
    @IBOutlet weak var sendPhotoBtn: UIButton!
    @IBOutlet weak var refreshBtn: UIButton!
    
    let communicator = ChatCommunicator.shared
    var lastMessageID = 1
    var incomingMessages = [MessageItem]()
    let logManager = LogManager()
    
    let refreshLock = NSLock()
    var shouldRefreshAgain = false
    var userName = "drinkShop客服人員"
    override func viewDidLoad() {
        super.viewDidLoad()
        //取得user授權
        PHPhotoLibrary.requestAuthorization { (status) in
            print("PHPhotoLibrary.requestAuthorization: \(status.rawValue)")
        }
        
        //收到推播,通知中心就會下載並自動刷新
        NotificationCenter.default.addObserver(self, selector: #selector(doRefreshJob), name: .didReceiveNotification, object: nil)
        
        //Get back the lastMessageID from UserDefaults.
        lastMessageID = UserDefaults.standard.integer(forKey: LASTMESSAGE_ID_KEY)
        if lastMessageID == 0 {
           lastMessageID = 1
        }
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inputTextField.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        sendMsgBtn.isEnabled = true
        sendPhotoBtn.isEnabled = true
        refreshBtn.isEnabled = true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let startIndex: Int = {//從第幾筆開始讀取
            var result = logManager.count - 20
            if result < 0 {
               result = 0
            }
            return result
        }()//create a property
        for i in 0..<(logManager.count - startIndex) {
            guard let message = logManager.getMessage(at: startIndex + i) else {
                assertionFailure("Fail to get message from logManager.")
                continue
            }
            incomingMessages.append(message)
        }
        handleIncomingMessages()
        doRefreshJob()
    }
    
    
    @IBAction func refreshBtnPressed(_ sender: Any) {
        doRefreshJob()
    }
    
    //刷新
    @objc func doRefreshJob(){
        
        let lock = NSObject()
        //Critical section. 鎖物件 鎖住thread,確保裡面每次都只有一個人,也可以鎖view controller
        objc_sync_enter(lock)
        // ...
        objc_sync_exit(lock)
        
//        refreshLock.lock()
//        // ...
//        refreshLock.unlock()
        
        guard refreshLock.try() else {//試著鎖
            shouldRefreshAgain = true //若有訊息進來,等等要重新下載
            return
        }
        
        communicator.retriveMessages(last: lastMessageID) { (result, error) in
            if let error = error {
                print("RetriveMessages error: \(error)")
                self.unlockRefreshLock()
                return
            }
            guard let result = result else {
                print("result is nil.")
                 self.unlockRefreshLock()
                return
            }
            print("RetriveMessages OK.")
            
            //Decode as [MessageItem].
            guard let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) else {
                print("Fail to generate jsonData.")
                 self.unlockRefreshLock()
                return
            }
            
            let decoder = JSONDecoder()
            guard let resultObject = try? decoder.decode(RetriveResult.self, from: jsonData) else {
                print("Fail to decode jsonData.")
                 self.unlockRefreshLock()
                return
            }
            print("resultObject: \(resultObject)")
            guard let messages = resultObject.messages, !messages.isEmpty else {
                print("messages is nil or empty.")
                 self.unlockRefreshLock()
                return
            }
            
            //Save messages into logManager.
            for message in messages {
                self.logManager.append(message)
            }
            
            //Keep and update lastMessageID.
            if let lastItem = messages.last {
                self.lastMessageID = lastItem.id
                UserDefaults.standard.set(self.lastMessageID, forKey: LASTMESSAGE_ID_KEY)
//                UserDefaults.standard.synchronize() // ios 10之後不用
            }
            
            self.incomingMessages += messages //附加訊息進去
            self.handleIncomingMessages()//處理訊息,每次處理一筆,處理完就移除,用遞迴處理
        }
    }
    
    
    func unlockRefreshLock() {//解鎖
        refreshLock.unlock()//先解鎖
        //Check if we should refresh again.
        if shouldRefreshAgain {
            shouldRefreshAgain = false
            doRefreshJob()//刷新
        }
    }
    
    func handleIncomingMessages() {
        //Pick the first one until incomingMessages become empty.一次檢查一筆 若有值就會轉成一般型別，直到incomingMessages變空。
        guard let item = incomingMessages.first else {
            unlockRefreshLock()
            return
        }
        incomingMessages.removeFirst() // Important!
        
        //Prepare for ChatItem.
        let text = "\(item.userName): \(item.message) (\(item.id))"
        let type: ChatSenderType = (item.userName == self.userName ? .fromMe : .fromOthers)
        
        var chatItem = ChatItem(text: text, image: nil, senderType: type)
        
        if item.type == 0 { // For text
            chatView.add(chatItem: chatItem)
            handleIncomingMessages()
        } else if item.type == 1 { // For photo
            //Try to load from cache first, if fail to load, then download it.
            if let image = logManager.load(image: item.message) {
                chatItem.image = image
                self.chatView.add(chatItem: chatItem)
                handleIncomingMessages() // Important!
                return // Important!
            }
            
          
            
            communicator.downloadPhoto(filename: item.message) { (data, error) in
                defer {
                    self.handleIncomingMessages()// 避免下載圖片失敗而接下來都沒有處理後續訊息部分
                }
                
                if let error = error {
                    print("Download fail: \(error)")
                    return
                }
                guard let data = data else {
                    print("photo data is nil.")
                    return
                }
                //Save data into logManager.
                self.logManager.save(image: data, filename: item.message)
                
                let image = UIImage(data: data)
                chatItem.image = image
                self.chatView.add(chatItem: chatItem)
                
              }
            }
        }
        
        
        @IBAction func sendPhotoBtnPressed(_ sender: Any) {
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
    //MARK: - UIImagePickerControllerDelegate Protocol Methods.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("info: \(info)")
        //mediaType will be Image or Movie
//        guard let type = info[UIImagePickerController.InfoKey.mediaType] as? String else {
        guard let type = info[.mediaType] as? String else {//簡化
            assertionFailure("Invalid type")
            return
        }
        if type == (kUTTypeImage as String) {
            guard let originalImage = info[.originalImage] as? UIImage else {
                assertionFailure("originalImage is nil")
                return
            }
            let resizedImage = originalImage.resize(maxEdge: 1024)!
            let jpgData = resizedImage.jpegData(compressionQuality: 0.8)
//            let pngData = resizedImage.pngData()
            print("jpgData: \(jpgData!.count)")
//            print("pngData: \(pngData!.count)")
            communicator.send(photoMessage: jpgData!, userName: self.userName) { (result, error) in
                if let error = error {
                    print("Upload photo fail: \(error)")
                    return
                }
                self.doRefreshJob()
            }
            
        } else if type == (kUTTypeMovie as String) {
            // ...
        }
        picker.dismiss(animated: true)// Important! picker才會收起來
    }
    
    
    func launchPicker(source: UIImagePickerController.SourceType) {//SourceType 資料來源、savedPhotosAlbum相機膠卷、camera、library
        
        //檢查來源是否有效
        guard UIImagePickerController.isSourceTypeAvailable(source) else {
            print("Invalid source type")
            return
        }
        let picker = UIImagePickerController()
        picker.delegate = self
//        picker.mediaTypes = ["public.image", "public.movie"]//照片影片都可以選
        picker.mediaTypes = [kUTTypeImage, kUTTypeMovie] as [String]//照片影片都可以選
        picker.sourceType = source
        picker.allowsEditing = true
        
        present(picker, animated: true)
    }
    
        @IBAction func sendTextBtnPressed(_ sender: Any) {
            guard let text = inputTextField.text, !text.isEmpty else {
                return
            }
            
            //收鍵盤
            inputTextField.resignFirstResponder()
            inputTextField.text = "" //清空輸入
            communicator.send(text: text, userName: self.userName) { (result, error) in
                if let error = error {
                    print("Send text error: \(error)")
                    return
                }
                print("Send text OK: \(result!)")
                self.doRefreshJob()
            }
        }
    
    //按下Done收鍵盤
    @IBAction func doneBarBtnPressed(_ sender: UIBarButtonItem) {
        inputTextField.resignFirstResponder()
    }
    
    }
    
    struct RetriveResult: Codable {
        var result: Bool
        var messages: [MessageItem]?
        enum CodingKeys: String, CodingKey {
            case result = "result"
            case messages = "Messages"
        }
}
