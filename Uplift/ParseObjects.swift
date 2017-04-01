//
//  ParseObjects.swift
//  Uplift
//
//  Created by Adam Cobb on 9/5/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import Foundation
import Parse

class DataStore{
    
    static var storeData:PFObject?
    
    static func refreshSync() throws{
        let data = try PFObject(withoutDataWithClassName: "DataStore", objectId: "DataStore1").fetch()
        try data.pin()
        storeData = data
    }
    
    static func refresh(_ callback:RefreshCallback){
        Async.run(Async.PRIORITY_INTERNETSMALL, AsyncSyncSuccessInterface(runTask: {
            try self.refreshSync()
            return true
            }, afterTask: { (success:Bool, message:String) in
                if success{
                    callback.success()
                }else{
                    callback.error(message)
                }
        }))
    }
    
    static func totalPostsAndComments()->Int{
        if let dataStore = storeData{
            if let result = dataStore["totalPostsAndComments"] as? Int{
                return result
            }
        }
        return 0
    }
    
    static func totalUplifts()->Int{
        if let dataStore = storeData{
            if let result = dataStore["totalUplifts"] as? Int{
                return result
            }
        }
        return 0
    }
    
    static func totalUsers()->Int{
        if let dataStore = storeData{
            if let result = dataStore["totalUsers"] as? Int{
                return result
            }
        }
        return 0
    }
    
    static func totalDonations()->Double{
        if let dataStore = storeData{
            if let result = dataStore["totalDonations"] as? Double{
                return result
            }
        }
        return 0
    }
    
    static func defaultCharity()->String{
        
        if let dataStore = storeData{
            if let result = dataStore["defualtCharity"] as? String{
                return result
            }
        }
        return "TSN9M6bLl6"
    }
}

class CurrentUser{
    
    static var userData:UserObject?
    
    static func user()->UserObject{
        if let userData = CurrentUser.userData{
            Async.run(Async.PRIORITY_INTERNETSMALL, AsyncInterface(runTask: {
                let userObject = UserObject()
                userObject.object = PFUser.current()
                CurrentUser.userData = userObject
            }))
            return userData
        }
        let userObject = UserObject()
        userObject.object = PFUser.current()
        CurrentUser.userData = userObject
        return userObject
    }
    
    static func userId()->String{
        if let userObject = user().object{
            if let userId = userObject.objectId{
                return userId
            }
        }
        return ""
    }
    
    static func email()->String{
        if let userObject = user().object{
            if let email = userObject.email{
                return email
            }
        }
        return ""
    }
    
    static func name()->String{
        return user().getName()!
    }
    
    static func profile()->Data{
        return user().getProfile()!
    }
    
    static func profileDimens()->[Int]{
    return user().getProfileDimens()!
    }
    
    static func thumb()->Data{
    return user().getThumb()!
    }
    
    static func thumbDimens()->[Int]{
    return user().getThumbDimens()!
    }
    
    static func postsAndComments()->Int{
        return user().getPostsAndComments()
    }
    
    static func uplifts()->Int{
        return user().getUplifts()
    }
    
    static func rank()->Int{
        return user().getRank()
    }
    
    static func charity()->String{
        return user().getCharity()!
    }
}

class UserObject{
    var object:PFUser!
    
    static func getUser(_ userId:String, callback:UserCallback){
        
        if(userId == CurrentUser.userId()){
            callback.success(CurrentUser.user())
            return
        }
        
        let userObject = UserObject()
        
        Async.run(Async.PRIORITY_INTERNETSMALL, AsyncSyncSuccessInterface(runTask: {
            do {
                userObject.object = try PFUser.query()!.fromLocalDatastore().getObjectWithId(userId) as! PFUser
                return true
            }catch{
                
                userObject.object = try PFUser.query()!.getObjectWithId(userId) as! PFUser
                try userObject.object!.pin()
                let _ = userObject.getThumb()
                return true
            }
            }, afterTask: {(success:Bool, message:String) in
                if (success) {
                    callback.success(userObject)
                } else {
                    callback.error(message)
                }
                
        }))
    }
    
    static func unpinUserObjectSync(_ userId:String){
        do{
            try PFUser.query()!.fromLocalDatastore().getObjectWithId(userId).unpin()
        }catch{}
    }
    
    func getName()->String?{
        if let name = object["name"]{
            if let name = name as? String{
                return name
            }
        }
        return nil
    }
    
    static var profileData:[String:Data] = [:]
    
    func getProfile()->Data?{
        if let profileData = UserObject.profileData[object.objectId!]{
            return profileData
        }
        
        if let file = object["profile"]{
            if let file = file  as? PFFile{
                do{
                    let data = try file.getData()
                    UserObject.profileData[object.objectId!] = data
                    return data
                }catch{}
            }
        }
        return nil
    }
    
    func getProfileDimens()->[Int]?{
    if let profileDimens = object["profileDimens"]{
        if let profileDimens = profileDimens  as? [Int]{
            return profileDimens
        }
    }
        return nil
    }
    
    static var thumbData:[String:Data] = [:]
    
    func getThumb()->Data?{
        
        if let thumbData = UserObject.thumbData[object.objectId!]{
            return thumbData
        }
        
        if let file = object["thumb"]{
            if let file = file  as? PFFile{
                do{
                    let data = try file.getData()
                    UserObject.thumbData[object.objectId!] = data
                    return data
                }catch{}
            }
        }
        return getProfile()
    }
    
    func getThumbDimens()->[Int]?{
        if let profileDimens = object["thumbDimens"]{
            if let profileDimens = profileDimens  as? [Int]{
                return profileDimens
            }
        }
        return getProfileDimens()
    }
    
    func getRank()->Int{
        if let rank = object["rank"]{
            if let rank = rank  as? Int{
                return rank
            }
        }
        return 0
    }
    
    func getUplifts()->Int{
        if let uplifts = object["uplifts"]{
            if let uplifts = uplifts as? Int{
                return uplifts
            }
        }
        return 0
    }
    
    func getPostsAndComments()->Int{
        if let uplifts = object["postsAndComments"]{
            if let uplifts = uplifts  as? Int{
                return uplifts
            }
        }
        return 0
    }
    
    func getCharity()->String?{
        if let charity = object["currentCharity"]{
            if let charity = charity  as? String{
                return charity
            }
        }
        return nil
    }
}

class PostOrCommentObject{
    var object:PFObject!
    
    func setUserId(_ userId:String){
        object["userId"] = userId
    }
    
    func getUserId()->String?{
        return object["userId"] as? String
    }
    
    func setLocation(_ location:String){
        object["location"] = location
    }
    
    func getLocation()->String?{
        return object["location"] as? String
    }
    
    func setGeoPoint(_ geoPoint:PFGeoPoint){
        object["geoPoint"] = geoPoint
    }
    
    func getDate()->Date{
        return object.createdAt!
    }
    
    func setText(_ text:String){
        object["text"] = text
    }
    
    func getText()->String?{
        return object["text"] as? String
    }
    
    func setContentType(_ contentType:Int){// -1: just text 1: image 2: video 3: gif 4:link
        object["contentType"] = contentType
    }
    
    func getContentType()->Int{
        if let contentType = object["contentType"] as? Int{
            return contentType
        }
        return 0
    }
    
    func setContentTitle(_ contentTitle:[String]){
        object["contentTitle"] = contentTitle
    }
    
    func getContentTitle()->[String]{
        return object["contentTitle"] as? [String] ?? []
    }
    
    func setMediaDimens(_ mediaDimens:[[Int]]){
        object["mediaDimens"] = mediaDimens
    }
    
    func getMediaDimens()->[[Int]]{
        return object["mediaDimens"] as? [[Int]] ?? []
    }
    
    func setThumbsDimens(_ thumbsDimens:[[Int]]){
        object["thumbsDimens"] = thumbsDimens
    }
    
    func getThumbsDimens()->[[Int]]{
        if let thumbsDimens = object["thumbsDimens"] as? [[Int]]{
            if thumbsDimens.count > 0{
                return thumbsDimens
            }
        }
        return getMediaDimens()
    }
    
    func setMedia(_ files:[PFFile]){
        object["media"] = files
    }
    
    static var mediaData:[String:[Data]] = [:]
    
    func getMedia()->[Data]{
        
        if let mediaData = PostOrCommentObject.mediaData[object.objectId!]{
            return mediaData
        }
        
        if let files = object["media"] as? [PFFile]{
            var datas:[Data] = []
            do{
                for file in files{
                    datas.append(try file.getData())
                }
                PostOrCommentObject.mediaData[object.objectId!] = datas
                return datas
            }catch{}
        }
        return []
    }
    
    func setThumbs(_ files:[PFFile]){
        object["thumbs"] = files
    }
    
    static var thumbsData:[String:[Data]] = [:]
    
    func getThumbs()->[Data]{
        
        if let thumbsData = PostOrCommentObject.thumbsData[object.objectId!]{
            return thumbsData
        }
        
        if let files = object["thumbs"] as? [PFFile]{
            var datas:[Data] = []
            do{
                for file in files{
                    datas.append(try file.getData())
                }
                if datas.count > 0{
                    PostOrCommentObject.thumbsData[object.objectId!] = datas
                    return datas
                }
            }catch{}
        }
        return getMedia()
    }
    
    func setContentText(_ contentText:[String]){
        object["contentText"] = contentText
    }
    
    func getContentText()->[String]{
        return object["contentText"] as? [String] ?? []
    }
    
    func setUplifters(_ uplifters:[String]){
        object["uplifters"] = uplifters
    }
    
    func getUplifters()->[String]{
        return object["uplifters"] as? [String] ?? []
    }
    
    func getUplifted()->Bool{
        return getUplifters().contains(CurrentUser.userId())
    }
    
    func setUplifts(_ uplifts:Int){
        object["uplifts"] = uplifts
    }
    
    func getUplifts()->Int{
        if let uplifts = object["uplifts"] as? Int{
            return uplifts
        }
        return 0
    }
    
    func setFlaggers(_ flaggers:[String]){
        object["flaggers"] = flaggers
    }
    
    func getFlaggers()->[String]{
        return object["flaggers"] as? [String] ?? []
    }
    
    func getFlagged()->Bool{
        return getFlaggers().contains(CurrentUser.userId())
    }
    
    func flag(){
        var flaggers = getFlaggers()
        if(!flaggers.contains(CurrentUser.userId())){
            flaggers.append(CurrentUser.userId())
            setFlaggers(flaggers)
            object.saveEventually()
        }
    }
    
    func unFlag(){
        var flaggers = getFlaggers()
        if(flaggers.contains(CurrentUser.userId())){
            while let index = flaggers.index(of: CurrentUser.userId()){
                flaggers.remove(at: index)
            }
            setFlaggers(flaggers)
            object.saveEventually()
        }
    }
}

class PostObject: PostOrCommentObject {
    override init(){
        super.init()
        object = PFObject(className: "Post")
    }
    
    static func getPostObject(_ postId:String, mustRefresh:Bool, callback:PostCallback){
        
        let postObject = PostObject()
        
        Async.run(Async.PRIORITY_INTERNETSMALL, AsyncSyncSuccessInterface(runTask: {
            
            postObject.object = PFObject(withoutDataWithClassName: "Post", objectId: postId)
            
            if(!mustRefresh) {
                do {
                    try postObject.object.fetchFromLocalDatastore()
                    return true
                } catch {
                }
            }
            try postObject.object = postObject.object.fetch()
            try postObject.object.pin()
            let _ = postObject.getThumbs()
            return true
            
            }, afterTask: {
                (success:Bool, message:String) in
                
                if(success){
                    callback.success(postObject)
                }else{
                    callback.error(message)
                }
        }))
        
    }
    
    static func unpinPostObjectSync(_ postId:String){
    do{
        try PFObject(withoutDataWithClassName: "Post", objectId: postId).unpin()
    }catch{}
    }
    
    func setComments( _ comments:Int){
        object["comments"] = comments
    }
    
    func getComments()->Int{
        if let comments = object["comments"] as? Int{
            return comments
        }
        return 0
    }
}

class CommentObject: PostOrCommentObject{
    override init(){
        super.init()
        object = PFObject(className: "Comment")
        object["created"] = false
    }
    
    static func getCommentObject(_ commentId:String, mustRefresh:Bool, callback:CommentCallback){
        
        let commentObject = CommentObject()
        
        Async.run(Async.PRIORITY_INTERNETSMALL, AsyncSyncSuccessInterface(runTask: {
            
            commentObject.object = PFObject(withoutDataWithClassName: "Comment", objectId: commentId)
            
            if(!mustRefresh) {
                do {
                    try commentObject.object.fetchFromLocalDatastore()
                    return true
                } catch {
                }
            }
            try commentObject.object = commentObject.object.fetch()
            try commentObject.object.pin()
            let _ = commentObject.getThumbs()
            return true
            
            }, afterTask: {
                (success:Bool, message:String) in
                
                if(success){
                    callback.success(commentObject)
                }else{
                    callback.error(message)
                }
        }))
    }
    
    static func unpinCommentObjectSync(_ commentId:String){
        do{
            try PFObject(withoutDataWithClassName: "Comment", objectId: commentId).unpin()
        }catch{}
    }
    
    func setParentId( _ parentId:String){
        object["parentId"] = parentId
    }
    
    func getParentId()->String{
        return object["parentId"] as? String ?? ""
    }
}

class NotificationObject{
    var object:PFObject!
    
    init(){
        object = PFObject(className: "Notification")
    }
    
    static func getNotificationObject(_ objectId:String, callback:NotificationCallback){
        
        let notificationObject = NotificationObject()
        
        Async.run(Async.PRIORITY_INTERNETSMALL, AsyncSyncSuccessInterface(runTask: {
            notificationObject.object = PFObject(withoutDataWithClassName: "Notification", objectId: objectId)
            do {
                try notificationObject.object.fetchFromLocalDatastore()
            }catch{
                try notificationObject.object = notificationObject.object.fetch()
                try notificationObject.object.pin()
            }
            return true
            }, afterTask: {
                (success:Bool, message:String) in
                
                if (success){
                    callback.success(notificationObject)
                }else{
                    callback.error(message)
                }
        }))
        
    }
    
    static func unpinNotificationObjectSync(_ notificationId:String){
        do{
            try PFObject(withoutDataWithClassName: "Notification", objectId: notificationId).unpin()
        }catch{}
    }
    
    func getDate()->Date?{
        return object["time"] as? Date
    }
    
    func getType()->Int{
        if let type = object["type"] as? Int{
            return type
        }
        return 0
    }
    
    func getPreview()->String?{
        return object["preview"] as? String
    }
    
    func getRootId()->String?{
        return object["rootId"] as? String
    }
    
    func getPostId()->String?{
        return object["postId"] as? String
    }
    
    func getNumber()->Int{
        if let number = object["number"] as? Int{
            return number
        }
        return 0
    }
    
    func isRead()->Bool{
        if let numberRead = object["numberRead"] as? Int{
            return numberRead >= getNumber()
        }
        return false
    }
    
    func setRead(){
        object["numberRead"] = getNumber()
        object.saveEventually({
            (success:Bool, e:Error?) in
            
            Async.run(500, Async.PRIORITY_INTERNETBIG, AsyncInterface(runTask: {
                ViewController.context.notifications_refreshSync()
            }))
        })
    }
}

class ActivityObject{
    var object:PFObject!
    
    init(){
        object = PFObject(className: "Activity")
    }
    
    static func getActivityObject(_ objectId:String, callback:ActivityCallback){
        
        let activityObject = ActivityObject()
        
        Async.run(Async.PRIORITY_INTERNETSMALL, AsyncSyncSuccessInterface(runTask: {
            activityObject.object = PFObject(withoutDataWithClassName: "Activity", objectId: objectId)
            do {
                try activityObject.object.fetchFromLocalDatastore()
            }catch{
                try activityObject.object = activityObject.object.fetch()
                try activityObject.object.pin()
            }
            return true
        }, afterTask: {
            (success:Bool, message:String) in
            
            if (success){
                callback.success(activityObject)
            }else{
                callback.error(message)
            }
        }))
        
    }
    
    static func unpinActivityObjectSync(_ notificationId:String){
        do{
            try PFObject(withoutDataWithClassName: "Activity", objectId: notificationId).unpin()
        }catch{}
    }
    
    func getDate()->Date?{
        return object["time"] as? Date
    }
    
    func getType()->Int{
        if let type = object["type"] as? Int{
            return type
        }
        return 0
    }
    
    func getPreview()->String?{
        return object["preview"] as? String
    }
    
    func getRootId()->String?{
        return object["rootId"] as? String
    }
    
    func getPostId()->String?{
        return object["postId"] as? String
    }
    
    func getOwnerName()->String?{
        return object["ownerName"] as? String
    }
}

class CharityObject{
    var object:PFObject?
    
    init(obj:PFObject?){
        object = obj
    }
    
    static func getCharityObject(_ charityId:String, mustRefresh:Bool, callback:CharityCallback){
        
        let charityObject = CharityObject(obj: PFObject(withoutDataWithClassName: "Charity", objectId: charityId))
        
        Async.run(Async.PRIORITY_INTERNETSMALL, AsyncSyncSuccessInterface(runTask: {
            
            if(!mustRefresh) {
                do {
                    try charityObject.object!.fetchFromLocalDatastore()
                    return true
                } catch {
                }
            }
            try charityObject.object = charityObject.object!.fetch()
            try charityObject.object!.pin()
            let _ = charityObject.getPicture()
            return true
            
            }, afterTask: {
                (success:Bool, message:String) in
                
                if(success){
                    callback.success(charityObject)
                }else{
                    callback.error(message)
                }
        }))
    }
    
    static var pictureData:[String:Data] = [:]
    
    func getPicture()->Data?{
        
        if let pictureData = CharityObject.pictureData[object!.objectId!]{
            return pictureData
        }
        
        if let file = object!["picture"] as? PFFile{
            do{
                let data = try file.getData()
                CharityObject.pictureData[object!.objectId!] = data
                return data
            }catch{}
        }
        return nil
    }
    
    func getName()->String?{
        return object!["name"] as? String
    }
    
    func getShort()->String?{
        return object!["shortDescription"] as? String
    }
    
    func getLong()->String?{
        return object!["longDescription"] as? String
    }
    
    func getLink()->String?{
        return object!["link"] as? String
    }
    
    func getDonated()->Double{
        if let donated = object!["amountDonated"] as? Double{
            return donated
        }
        return 0
    }
}
