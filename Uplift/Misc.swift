//
//  Misc.swift
//  Uplift
//
//  Created by Adam Cobb on 9/5/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

/**
 * Created by Adam on 11/10/15.
 */
open class Misc {
    static let twoPi = 2.0 * M_PI
    
    static func dateToTime(_ date:Date?)->String{
        if(date == nil){
            return ""
        }
        
        var result = dateToTimeHelper(date!)
    if(result.substring(0, 2) == "1 "){
    result = result.substring(0, result.length() - 1)
    }
    return result
    }
    
    static func dateToTimeHelper(_ date:Date)->String{
    let now = Date()
    var seconds = (now.timeInMillis - date.timeInMillis) / 1000
    if(seconds < 0) {
    seconds = 28512000001
}

if(seconds < 60){
    return String(seconds) + " secs"
}else if(seconds / 60 < 60){
    return String(seconds / 60) + " mins"
}else if(seconds / 60 / 60 < 24){
    return String(seconds / 60 / 60) + " hrs"
}else if(seconds / 60 / 60 / 24 < 10){
    return String(seconds / 60 / 60 / 24) + " days"
}else{
    var result = ""
    let c = Calendar.current
    switch ((c as NSCalendar).component(.month, from: date)) {
    case 1:
        result += "Jan"
        break
    case 2:
        result += "Feb"
        break
    case 3:
        result += "Mar"
        break
    case 4:
        result += "Apr"
        break
    case 5:
        result += "May"
        break
    case 6:
        result += "Jun"
        break
    case 7:
        result += "Jul"
        break
    case 8:
        result += "Aug"
        break
    case 9:
        result += "Sep"
        break
    case 10:
        result += "Oct"
        break
    case 11:
        result += "Nov"
        break
    case 12:
        result += "Dec"
        break
    default: break
    }
    
    result += " " + String((c as NSCalendar).component(.day, from: date))
    if(seconds >= 28512000000){ //330 days
        result += ", " + String((c as NSCalendar).component(.year, from: date))
    }
    return result
}
}

    static func encodeImage(_ image:UIImage?)->Data?{
    
        if let image = image{
            return UIImagePNGRepresentation(image)
        }
    
        return nil
}

    static func decodeImage(_ data:Data)->UIImage{
        return UIImage(data: data)!
}

    static func pageToModes(_ page:Int)->[Int]{
    var p = 0
    for i in 0 ..< ViewController.context.modeNames.count{
        for j in 0 ..< ViewController.context.submodeNames[i].count{
            if p == page{
                return [i, j]
            }
            p += 1
        }
    }
    return [0, 0]
}

    static func modeToPage(_ mode:Int, _ submode:Int)->Int{
    var p = 0
        for i in 0 ..< ViewController.context.modeNames.count{
            for j in 0 ..< ViewController.context.submodeNames[i].count{

            if(mode == i && submode == j){
                return p
            }
            p += 1
        }
    }
    return 0
}

    static func addCommas(_ string:String)->String{
        var string = string
    var decimalIndex = string.indexOf(".")
    if(decimalIndex == -1){
        decimalIndex = string.length()
    }
        for i in stride(from: (decimalIndex - 3), to: 0, by: -3){
        string = string.substring(0, i) + "," + string.substring(i)
    }
    return string
}

    static func dollars(_ amount:Double)->String{
    var amountS = String(Int(floor(amount * 100.0)))
        for _ in stride(from: amountS.length(), to: 3, by: 1){
            amountS = "0" + amountS
    }
    amountS = amountS.substring(0, amountS.length() - 2) + "." + amountS.substring(amountS.length() - 2)
    
    amountS = "$" + addCommas(amountS)
    return amountS
}

    static func floorText(_ value:Double)->String{
    let place = value >= 10 ? floor(log10(value)) : 0
    let value = value - value.truncatingRemainder(dividingBy: pow(10, place))
    return EnglishNumberToWords.convert(value)
}

    static func addSuffix(_ number:Int)->String{
    var numberS = addCommas(String(number))
    if((number / 10) % 10 == 1){ //11th, 12th, etc
        numberS += "th"
    }else {
        switch (number % 10) {
        case 1:
            numberS += "st"
            break
        case 2:
            numberS += "nd"
            break
        case 3:
            numberS += "rd"
            break
        default:
            numberS += "th"
            break
        }
    }
    return numberS
}

    static func isBetween(_ value:CGFloat, num1:CGFloat, num2:CGFloat, orWithin1:Bool)->Bool{
    if(orWithin1 && (abs(value - num1) < 1 || abs(value - num2) < 1)){
        return true
    }
    
    if((value > num1 && value < num2) || (value < num1 && value > num2)){
        return true
    }
    
    return false
}

    static func isInWindow(_ view:UIView)->Bool{
    let loc = getLocationInViews(view)
    return loc.x < ViewController.context.screenWidth! && loc.x > -view.frame.width && loc.y < ViewController.context.screenHeight! && loc.y > -view.frame.height
}

    static func isInRange(_ view:UIView)->Bool{
    let loc = getLocationInViews(view)
    return loc.x < ViewController.context.screenWidth! && loc.x > -view.frame.width && loc.y < ViewController.context.screenHeight! * 2 && loc.y > -view.frame.height - ViewController.context.screenHeight!
}

    static func getLocationInViews(_ view:UIView)->CGPoint{
    var loc = view.superview!.convert(view.frame.origin /*leave it*/, to: nil)
    loc.y -= ViewController.context.upperWindowMargin
    return loc
}

    static func linkifyLink(_ link:String)->String{
        var link = link
    
    if(link.length() < 4 || link.substring(0, 4) != "http"){
        link = "http://" + link
    }
    return link
}

    static func contentTypeName(_ type:Int)->String{
    switch (type){
    case 1:
        return "Image"
    case 2:
        return "Video"
    case 3:
        return "Link"
    case 4:
        return "GIF"
    case 5:
        return "YouTube Video"
    default:
        return ""
    }
}

    static func contentTypeExtension(_ type:Int)->String{
    switch (type){
    case 1:
        return ".png"
    case 2:
        return ".mp4"
    case 3:
        return ".png"
    case 4:
        return ".gif"
    case 5:
        return ""
    default:
        return ""
    }
}

    static func contentTypeImage(_ type:Int)->UIImage{
        var name:String = ""
    switch (type){
    case 1:
        name = "image"
    case 2:
        name = "video"
    case 3:
        name = "link"
    case 4:
        name = "gif"
    case 5:
        name = "youtube"
    default: break
    }
    return UIImage(named: name)!
}

static var currentBitmapId = 0

static func generateBitmapId()->String{
    currentBitmapId = currentBitmapId % 1000000 + 1
    return "bitmap" + String(currentBitmapId)
}
}

