//
//  DocumentData.swift
//  视讼
//
//  Created by KlausZhang on 2020/8/4.
//  Copyright © 2020 KlausZhang. All rights reserved.
//

import Foundation
import RealmSwift


class Parts: Object {
    @objc dynamic var item:String = ""
    let owner = LinkingObjects(fromType: Document.self, property: "parts")
}
class Document: Object {
    @objc dynamic var id = 0
    override static func primaryKey() -> String? {
        return "id"
    }
    @objc dynamic var title: String = ""
    @objc dynamic var createTime: String = ""
    @objc dynamic var clientName: String = ""
    @objc dynamic var clientNation: String = ""
    @objc dynamic var clientAddress: String = ""
    @objc dynamic var timeAxisInfo: String = ""
    @objc dynamic var relationshipInfo: String = ""
    @objc dynamic var clickTimes: Int32 = -1
    @objc dynamic var clickTimesForCD: Int32 = 0
    @objc dynamic var clickTimesForTA: Int32 = 0
    @objc dynamic var clickTimesForRS: Int32 = 0
    @objc dynamic var timeAxisPic: Data?
    @objc dynamic var thumbnail: Data?
    let parts = List<Parts>()
}
