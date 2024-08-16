//
//  ApiModel.swift
//  Study-RxSwift
//
//  Created by GENKIFUJIMOTO on 2024/08/16.
//

struct Api : Codable {
    var photos:[ListItem]
    
    init(photos:[ListItem]) {
        self.photos = photos
    }
}

struct ListItem : Codable {
    var alt:String?
    var photographer:String?
    var src:srctype?
    
    struct srctype:Codable {
        var tiny:String?
        var large:String?
    }
}
