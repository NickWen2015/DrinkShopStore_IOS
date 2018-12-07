//
//  Activities.swift
//  DrinkShopStore_IOS
//
//  Created by 周芳如 on 2018/11/3.
//  Copyright © 2018 Nick Wen. All rights reserved.
//

import Foundation



struct NewsItem: Codable {
    var id: Int
    var name: String
    var sDate: String
    var eDate: String
   

    enum CodingKeys: String, CodingKey {
        case id = "activity_id"
        case name = "activity_name"
        case sDate = "activity_date_start"
        case eDate = "activity_date_end"
   
    
    }
}

extension Communicator {
    
    //取得所有資訊
    func retriveNewsInfo(completion: @escaping DoneHandler) {
        let parameters:[String : Any]  = [ACTION_KEY: "getAllNews"]
        
        return doPost(urlString: NEWSSERVLET_URL, parameters: parameters, completion: completion)
    }
    
    //新增
    func newsInsert(news: String, photo: String, completion: @escaping DoneHandler) {
        
        let parameters: [String: Any] = [ACTION_KEY: "newsInsert", NEWS_KEY: news, IMAGEBASE64: photo]
        doPost(urlString:NEWSSERVLET_URL, parameters:parameters, completion:completion)
    }
    
    //修改
    func newsUpdate(news: String, photo: String, completion: @escaping DoneHandler) {
        
        let parameters: [String: Any] = [ACTION_KEY: "newsUpdate", NEWS_KEY: news, IMAGEBASE64: photo]
        doPost(urlString:NEWSSERVLET_URL, parameters:parameters, completion:completion)
    }
    
    //刪除
    func newsDelete(news: String, id: Int, completion: @escaping DoneHandler) {
        
        let parameters: [String: Any] = [ACTION_KEY: "newsDelete", NEWS_KEY: news, ID_KEY: id]
        doPost(urlString:NEWSSERVLET_URL, parameters:parameters, completion:completion)
    }
    
}
