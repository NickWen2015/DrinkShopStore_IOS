//
//  LogManager.swift
//  HelloMyPushMessage
//
//  Created by Nick Wen on 2018/10/31.
//  Copyright © 2018 Nick Wen. All rights reserved.
//

import Foundation
import SQLite

//MARK: - Structs for incoming messages.
struct MessageItem: Codable {
    var id: Int
    var type: Int
    var userName: String
    var message: String
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "Type"
        case userName = "UserName"
        case message = "Message"
    }
}

// 
class LogManager {
    
    static let tableName = "messageLog"
    static let midKey = "mid"
    static let idKey = "id"
    static let typeKey = "type"
    static let messageKey = "message"
    static let usernameKey = "username"
    
    //SQLite.swift support
    var db: Connection!//資料庫
    var logTable = Table(tableName)//資料表
    var midColumn = Expression<Int64>(midKey)//對應欄位
    var idColumn = Expression<Int64>(idKey)//對應欄位
    var typeColumn = Expression<Int64>(typeKey)//對應欄位
    var messageColumn = Expression<String>(messageKey)//對應欄位
    var usernameColumn = Expression<String>(usernameKey)//對應欄位
    
    var messageIDs = [Int64]()
    
    init() {
        //聊天記錄存在documents目錄
        let filemanager = FileManager.default
        let documentsURL = filemanager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullURLPath = documentsURL.appendingPathComponent("log.sqlite").path
        var isNewDB = false
        if !filemanager.fileExists(atPath: fullURLPath) {//判斷是否為第一次執行，檔案是否存在
            isNewDB = true
        }
        // Prepare connection of DB. 準備連結DB
        do {
            db = try Connection(fullURLPath)//執行後就會建立file
        } catch {//異常如檔案空間滿了
            assertionFailure("Fail to create connection.")
            return
        }
        
        //Create Table at the first time.
        if isNewDB {
            assertionFailure("Fail to create table.")
//            do {
//                let command = logTable.create { (builder) in
//                    builder.column(midColumn, primaryKey: true)//PK
//                    builder.column(idColumn)//依序建立
//                    builder.column(messageColumn)//依序建立
//                    builder.column(typeColumn)//依序建立
//                    builder.column(usernameColumn)//依序建立
//                }
//                try db.run(command)
//                print("Log table is created OK.")
//            } catch {
//                assertionFailure("Fail to create table: \(error)")
//            }
        } else {
            // Keep mid into messageIDs
            
            do {
                // SELECT * FROM "messageLog";
                for message in try db.prepare(logTable) {
                    messageIDs.append(message[midColumn])
                }
            } catch {
                assertionFailure("Fail to excute prepare command: \(error)")
            }
            print("There are total \(messageIDs.count) messages in DB.")
        }
    }
    
    var count: Int {// computed property.等同DB訊息數量
        return messageIDs.count
    }
    
    //add 寫入資料
    func append(_ message: MessageItem) {
        let command = logTable.insert(messageColumn <- message.message,
                                      typeColumn <- Int64(message.type),
                                      idColumn <- Int64(message.id),
                                      usernameColumn <- message.userName)
        do {
            let newMessageID = try db.run(command)//取得新增時的pk
            messageIDs.append(newMessageID)//回存到array
        } catch  {
            assertionFailure("Fail to insert new message: \(error)")
        }
        
        
    }
    
    //get 讀取資料
    func getMessage(at: Int) -> MessageItem? {
        guard at >= 0 && at < count else { //確認不會outofindex error
            assertionFailure("Invalid message index.")
            return nil
        }
        let targetMessageID = messageIDs[at]// get index id
        
        //SELECT * FROM "logMessage" Where mid = xxxx;
        let results = logTable.filter(midColumn == targetMessageID)
        
        //pick the first one.
        do {
            guard let message = try db.pluck(results) else {//pluck 多筆取一筆
                assertionFailure("Fail to get the only one result.")
                return nil
            }
            return MessageItem(id: Int(message[idColumn]),
                               type: Int(message[typeColumn]),
                               userName: message[usernameColumn],
                               message: message[messageColumn])
        } catch  {
            print("Pluck fail: \(error)")
        }
        return nil
    }
    
    //MARK: - Photo cache support.
    func load(image filename: String) -> UIImage? {
        let url = urlFor(filename)
        return UIImage(contentsOfFile: url.path)//UIImage判斷是否可讀寫
    }
    
    func save(image data: Data, filename: String) {
        let url = urlFor(filename)
        do {
            try data.write(to: url)
        } catch {
            assertionFailure("Fail to save image: \(error)")
        }
    }
    
    private func urlFor(_ filename: String) -> URL {
        let filemanager = FileManager.default
        let documentsURL = filemanager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent(filename)
    }
}
