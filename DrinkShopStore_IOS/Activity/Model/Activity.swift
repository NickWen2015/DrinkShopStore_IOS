//
//  Activities.swift
//  DrinkShopStore_IOS
//
//  Created by 周芳如 on 2018/11/3.
//  Copyright © 2018 Nick Wen. All rights reserved.
//

import Foundation


struct Activity: Codable {
    
    let activityName: String
    let activityStartDate: String
    let activityEndDate: String
//    let activityImage: String
    
    private static var fileURL: URL{
        var documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        documentDir.appendPathComponent("activities")
        documentDir.appendPathExtension("plist")
        print(documentDir.absoluteString)
        return documentDir
}
    
    //存檔
    static func save(_ activities:[Activity]){
        let encoder = PropertyListEncoder()
       
        
        if let encodedActivities = try?
            encoder.encode(activities) {
            try! encodedActivities.write(to: fileURL, options: .noFileProtection)
        }
    }
    static func load() -> [Activity]?{
        let decoder = PropertyListDecoder()
        if let decodedActivities = try?
            Data(contentsOf: fileURL){
            let result = try?
                decoder.decode(Array<Activity>.self, from: decodedActivities)
            return result
        }
        return nil
        
    }
    
 
    
}
