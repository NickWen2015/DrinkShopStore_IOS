//
//  Communicator.swift
//  DrinkShopStore_IOS
//
//  Created by 周芳如 on 2018/11/7.
//  Copyright © 2018 Nick Wen. All rights reserved.
//

import Foundation
import Alamofire


//共用參數
let ACCOUNT_KEY = "name"
let PASSWORD_KEY = "password"
let ACTION_KEY = "action"
let ID_KEY = "id"
let IMAGESIZE_KEY = "imageSize"
let PRODUCT_ID_KEY = "product_id" // 新增 by Peko
let PRODUCT_KEY = "product" // 新增 by Peko
let IMAGEBASE64_KEY = "imageBase64" // 新增 by Peko
let ORDERID_KEY = "orderId" // 新增 by Peko
let ORDERSTATUS_KEY = "orderStatus" // 新增 by Peko
let CATEGORYNAME_KEY = "categoryName" // 新增 by Peko
let NEWS_KEY = "news"
let IMAGEBASE64 = "imageBase64"
let SDATE_KEY = "sDate"
let EDATE_KEY = "eDate"

//result:[String:Any] is dictionary declaration.
typealias DoneHandler = (_ result: Any?, _ error:Error?) -> Void
typealias DownloadDoneHandler = (_ result:Data?, _ error:Error?) -> Void


class Communicator {  //Singleton instance 單一實例模式
    
    // SERVER_URL 常數
    
    static let BASEURL = Common.SERVER_URL
    let MEMBERSERVLET_URL = BASEURL + "MemberServlet"
    let NEWSSERVLET_URL = BASEURL + "NewsServlet"
    let ORDERSSERVLET_URL = BASEURL + "OrdersServlet"
    let PRODUCTSERVLET_URL = BASEURL + "ProductServlet"
    let COUPON_ID_KEY = "coupon_id"
    let COUPONSERVLET_URL = BASEURL + "CouponServlet"
    
    static let shared = Communicator()
    
    //MARK: - Common methods.
    func getPhotoById(photoURL: String, id: Int, imageSize: Int = 1080, completion: @escaping DownloadDoneHandler) {
        let parameters:[String : Any] = [ACTION_KEY: "getImage", ID_KEY: id, IMAGESIZE_KEY: imageSize]
        
        return doPostForPhoto(urlString: photoURL, parameters: parameters, completion: completion)
    }
    
    // 發Request到Server(圖片) // 拿掉private by Peko
    func doPostForPhoto(urlString:String, parameters:[String: Any], completion: @escaping DownloadDoneHandler) {
        Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseData { response in
            
            self.handlePhoto(response: response, completion: completion)
        }
    }
    
    // 處理Server回傳的圖片
    private func handlePhoto(response: DataResponse<Data>, completion: DownloadDoneHandler) {
        guard let data = response.data else {
            print("data is nil")
            let error = NSError(domain: "Invalid Image object.", code: -1, userInfo: nil)
            completion(nil, error)
            return
        }
        completion(data, nil)
    }
    
    
    // 發Request到Server(文字)
    func doPost(urlString:String, parameters:[String: Any], completion: @escaping DoneHandler) {
        
        Alamofire.request(urlString, method: .post , parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            self.handleJSON(response: response, completion: completion)
        }
    }
    
    // 處理Server回傳的JSON
    private func handleJSON(response: DataResponse<Any>, completion: DoneHandler) {
        switch response.result {
        case .success(let json):
            print("Get success response: \(json)")
            completion(json, nil)
        case .failure(let error):
            print("Server respond error: \(error)")
            completion(nil, error)
        }
    }
}








