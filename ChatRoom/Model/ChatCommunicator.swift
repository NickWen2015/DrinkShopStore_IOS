//
//  Communicator.swift
//  HelloMyPushMessage
//
//  Created by Nick Wen on 2018/10/24.
//  Copyright © 2018 Nick Wen. All rights reserved.
//

import Foundation
import Alamofire

let GROUPNAME = "drinkShop"
//let MY_NAME = "test2"

// JSON Keys (固定)
let CID_KEY = "id"
let USERNAME_KEY = "UserName"
let MESSAGES_KEY = "Messages"
let MESSAGE_KEY = "Message"
let DEVICETOKEN_KEY = "DeviceToken"
let GROUPNAME_KEY = "GroupName"
let LASTMESSAGE_ID_KEY  = "LastMessageID"
let TYPE_KEY = "Type"
let DATA_KEY = "data"
let RESULT_KEY = "result"

//result:[String:Any] is dictionary declaration.
typealias CDoneHandler = (_ result:[String:Any]?, _ error:Error?) -> Void
typealias CDownloadDoneHandler = (_ result:Data?, _ error:Error?) -> Void


class ChatCommunicator {//Singleton instance 單一實例模式
    
    // Constants (固定)
    static let BASEURL = "http://class.softarts.cc/PushMessage/"
//    static let BASEURL = "http://192.168.1.85:80/PushMessage/"
    let UPDATEDEVICETOKEN_URL = BASEURL + "updateDeviceToken.php"
    let RETRIVE_MESSAGES_URL = BASEURL + "retriveMessages2.php"
    let SEND_MESSAGE_URL = BASEURL + "sendMessage.php"
    let SEND_PHOTOMESSAGE_URL = BASEURL + "sendPhotoMessage.php"
    let PHOTO_BASE_URL = BASEURL + "photos/"
    
    static let shared = ChatCommunicator()
    private init() {
        
    }
    
    //MARK: - Public methods.
    //回報deviceToken的方法
    func update(deviceToken: String, userName: String, completion: @escaping CDoneHandler) {//prepare dictionary ,it's easy cast to json.
        let parameters = [USERNAME_KEY: userName,
                          DEVICETOKEN_KEY: deviceToken,
                          GROUPNAME_KEY: GROUPNAME]
        print("update: \(parameters)")
        doPost(urlString: UPDATEDEVICETOKEN_URL, parameters: parameters, completion: completion)
    }
    
    //send的方法
    func send(text message: String, userName: String, completion: @escaping CDoneHandler) {
        
        let parameters = [ USERNAME_KEY:userName, MESSAGE_KEY:message, GROUPNAME_KEY:GROUPNAME]
        print("send: \(parameters)")
        doPost(urlString: SEND_MESSAGE_URL, parameters: parameters, completion: completion)
    }
    //retriveMessages的方法
    func retriveMessages(last messageID: Int,completion: @escaping CDoneHandler) {
        
        let parameters: [String: Any] = [LASTMESSAGE_ID_KEY:messageID, GROUPNAME_KEY:GROUPNAME]
        print("retriveMessages: \(parameters)")
        doPost(urlString: RETRIVE_MESSAGES_URL, parameters: parameters, completion: completion)
    }
    
    
    func downloadPhoto(filename: String, completion: @escaping CDownloadDoneHandler) {
        let finalURLString = PHOTO_BASE_URL + filename
        Alamofire.request(finalURLString).responseData { (response) in
            switch response.result {
            case .success(let data):
                print("Photo Download OK: \(data.count) bytes")
                completion(data, nil)
            case .failure(let error):
                print("Photo Download Fail: \(error)")
                completion(nil, error)
            }
        }
        
    }
    
    func send(photoMessage data: Data, userName: String, completion: @escaping CDoneHandler) {
        let parameters = [ USERNAME_KEY:userName, GROUPNAME_KEY:GROUPNAME]
        print("sendphotoMessage: \(parameters)")
        doPost(urlString: SEND_PHOTOMESSAGE_URL, parameters: parameters, data: data, completion: completion)
    }
    
    private func doPost(urlString:String, parameters:[String: Any] ,data: Data ,completion: @escaping CDoneHandler) {
        let jsonData = try! JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        Alamofire.upload(multipartFormData: { (formData) in
            // 組織要上傳的內容資料
            formData.append(jsonData, withName: DATA_KEY)
            formData.append(data, withName: "fileToUpload", fileName: "image.jpg", mimeType: "image/jpg")
        }, to: urlString, method: .post) { (encodingResult) in
            // encodingResult 資料成功or失敗
            switch encodingResult {
//            case .success(let request, let fromDisk, let url):
            case .success(let request, _, _):
                print("Post Encoding OK.")
                request.responseJSON { (response) in
                    self.handleJSON(response: response, completion: completion)
                }
            case .failure(let error):
                print("Post Encoding Fail: \(error)")
                completion(nil, error)
            }
        }
        
    }
    
    private func doPost(urlString:String, parameters:[String: Any], completion: @escaping CDoneHandler) {
        
        let jsonData = try! JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        
        let jsonString = String(data: jsonData, encoding: .utf8)!//jsonData to jsonString
        let finalParamters: [String: Any] = [DATA_KEY: jsonString]
        
        //URLEncoding.default >> data = ....
        //JSONEncoding.default >> {"data":"...."}
        //let header = ["AuthorizationKey":"..."]
        //Alamofire send request
        Alamofire.request(urlString, method: .post, parameters: finalParamters, encoding: URLEncoding.default).responseJSON { (response) in
            self.handleJSON(response: response, completion: completion)
        }
    }
    
    private func handleJSON(response: DataResponse<Any>, completion: CDoneHandler) {
        switch response.result {
        case .success(let json)://enum 夾帶參數
            print("Get success response: \(json)")
            guard let finalJson = json as? [String: Any] else {
                let error = NSError(domain: "Invalid JSON object.", code: -1, userInfo: nil)//JSON 解不出來
                completion(nil, error)
                return
            }
            guard let result = finalJson[RESULT_KEY] as? Bool,
                result == true else {
                    let error = NSError(domain: "Server respond false or not result.", code: -1, userInfo: nil)
                    completion(nil, error)
                    return
            }
            completion(finalJson, nil)
        case .failure(let error):
            print("Get success error: \(error)")
            completion(nil, error)
        }
    }
    
}
