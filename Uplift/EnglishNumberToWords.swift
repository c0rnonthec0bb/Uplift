//
//  EnglishNumberToWords.swift
//  Uplift
//
//  Created by Adam Cobb on 9/6/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import Foundation

open class EnglishNumberToWords {
    open static func convert(_ number:Double) -> String{
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        return formatter.string(from: NSNumber(value: number))!
    }
}
