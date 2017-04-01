//
//  Tag.swift
//  Uplift
//
//  Created by Adam Cobb on 9/26/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import Foundation

class Tag {
    static private var lastTag = 1000
    
    static private var lookup:[String:Int] = [:]
    
    static func getTag(_ string:String)->Int{
        if let tag = lookup[string]{
            return tag
        }
        
        lastTag += 1
        lookup[string] = lastTag
        return lastTag
    }
    
    static func getString(_ tag:Int)->String{
        for pair in lookup{
            if pair.value == tag{
                return pair.key
            }
        }
        return ""
    }
}
