//
//  Refresh.swift
//  Uplift
//
//  Created by Adam Cobb on 9/22/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit
import Parse

class Refresh {
    
    static func refreshPage(_ mode:Int, _ submode:Int){
        
        if(ViewController.context.refreshing[Misc.modeToPage(mode, submode)]){
            return
        }
        
        if(CurrentUser.user().object == nil){
            return
        }
        
        let layoutNum = Misc.modeToPage(mode, submode)
        
        let _ = ViewController.context.view_scrolls[layoutNum].animate().translationY(RefreshView.refreshH).setDuration(300).setInterpolator(.decelerate)
        ViewController.context.view_refreshes[layoutNum].animateRefresh()
        
        ViewController.context.refreshing[layoutNum] = true
        ViewController.context.lastRefresh[layoutNum] = Int64(Date().timeIntervalSince1970 * 1000)
        
        let sortByUplifts = ViewController.context.view_switches[layoutNum].byUplifts
        
        switch (mode){
        case 0:
            switch (submode){
            case 0:
                refreshLocal(sortByUplifts)
                return
            case 1:
                refreshRegional(sortByUplifts)
                return
            case 2:
                refreshGlobal(sortByUplifts)
                return
            default: break
            }
            break
        case 1:
            switch (submode){
            case 0:
                refreshAllUsers()
                return
            case 1:
                refreshAllPosts()
                return
            default: break
            }
            break
        case 2:
            switch (submode){
            case 0:
                refreshNotifications()
                return
            case 1:
                refreshActivity()
                return
            default: break
            }
            break
        case 3:
            refreshSettings()
            return
        default: break
        }
    }
    
    static func refreshLocal(_ sortByUplifts:Bool){
        
        Async.run(Async.PRIORITY_INTERNETBIG, AsyncSyncSuccessInterface(runTask: {
            
            var map:[String : Any] = [:]
            map["sortByUplifts"] = sortByUplifts
            map["geoPoint"] = Local.getCurrentGeoPoint()
            map["radius"] = 5.0
            
            let array = try PFCloud.callFunction("getRegionalList", withParameters: map) as! [String]
            
            let oldList = Local.readList(0, 0, sortByUplifts)
            let allIndexedLists = Local.readAllOtherIndexedLists(0, 0, sortByUplifts)
            
            for i in 0 ..< min(Local.readIndex(0, 0, sortByUplifts), oldList.count) {
                let item = oldList[i]
                if (!array[0..<min(10, array.count)].contains(item) && !allIndexedLists.contains(item)) {
                    PostObject.unpinPostObjectSync(item)
                    
                    let commentsList = Local.readCommentsList(item, false)
                    for j in 0 ..< min(Local.readCommentsIndex(item, false), commentsList.count){
                        CommentObject.unpinCommentObjectSync(commentsList[j])
                    }
                    Local.writeCommentsIndex(item, false, 0)
                    Local.writeCommentsIndex(item, true, 0)
                }
            }
            
            Local.writeIndex(0, 0, sortByUplifts, 0)
            Local.writeList(0, 0, sortByUplifts, array)
            
            Refresh.fetchNextItems(0, 0, sortByUplifts, 10)
            return true
            }, afterTask: {
                (success:Bool, message:String) in
                if (!success) {
                    Toast.makeText(ViewController.context, "Failed to refresh local posts.", Toast.LENGTH_LONG)
                    print("local error: " + message)
                    Update.updateLayout(0, 0, false)
                }
        }))
    }
    
    static func refreshRegional(_ sortByUplifts:Bool){
        
        Async.run(Async.PRIORITY_INTERNETBIG, AsyncSyncSuccessInterface(runTask: {
            var map:[String : Any] = [:]
            map["sortByUplifts"] = sortByUplifts
            map["geoPoint"] = Local.getCurrentGeoPoint()
            map["radius"] = 400.0
            
            let array = try PFCloud.callFunction("getRegionalList", withParameters: map) as! [String]
            
            let oldList = Local.readList(0, 1, sortByUplifts)
            let allIndexedLists = Local.readAllOtherIndexedLists(0, 1, sortByUplifts)
            
            for i in 0 ..< min(Local.readIndex(0, 1, sortByUplifts), oldList.count) {
                let item = oldList[i]
                if (!array[0..<min(10, array.count)].contains(item) && !allIndexedLists.contains(item)) {
                    PostObject.unpinPostObjectSync(item)
                    
                    let commentsList = Local.readCommentsList(item, false)
                    for j in 0 ..< min(Local.readCommentsIndex(item, false), commentsList.count){
                        CommentObject.unpinCommentObjectSync(commentsList[j])
                    }
                    Local.writeCommentsIndex(item, false, 0)
                    Local.writeCommentsIndex(item, true, 0)
                }
            }
            
            Local.writeIndex(0, 1, sortByUplifts, 0)
            Local.writeList(0, 1, sortByUplifts, array)
            
            Refresh.fetchNextItems(0, 1, sortByUplifts, 10)
            return true
            }, afterTask: {
                (success:Bool, message:String) in
                if (!success) {
                    Toast.makeText(ViewController.context, "Failed to refresh regional posts.", Toast.LENGTH_LONG)
                    Update.updateLayout(0, 1, false)
                }
        }))
    }
    
    static func refreshGlobal(_ sortByUplifts:Bool){
        
        Async.run(Async.PRIORITY_INTERNETBIG, AsyncSyncSuccessInterface(runTask: {
            var map:[String : Any] = [:]
            map["sortByUplifts"] = sortByUplifts
            
            let array = try PFCloud.callFunction("getGlobalList", withParameters: map) as! [String]
            
            let oldList = Local.readList(0, 2, sortByUplifts)
            let allIndexedLists = Local.readAllOtherIndexedLists(0, 2, sortByUplifts)
            
            for i in 0 ..< min(Local.readIndex(0, 2, sortByUplifts), oldList.count) {
                let item = oldList[i]
                if (!array[0..<min(10, array.count)].contains(item) && !allIndexedLists.contains(item)) {
                    PostObject.unpinPostObjectSync(item)
                    
                    let commentsList = Local.readCommentsList(item, false)
                    for j in 0 ..< min(Local.readCommentsIndex(item, false), commentsList.count){
                        CommentObject.unpinCommentObjectSync(commentsList[j])
                    }
                    Local.writeCommentsIndex(item, false, 0)
                    Local.writeCommentsIndex(item, true, 0)
                }
            }
            
            Local.writeIndex(0, 2, sortByUplifts, 0)
            Local.writeList(0, 2, sortByUplifts, array)
            
            Refresh.fetchNextItems(0, 2, sortByUplifts, 10)
            return true
            }, afterTask: {
                (success:Bool, message:String) in
                if (!success) {
                    Toast.makeText(ViewController.context, "Failed to refresh global posts.", Toast.LENGTH_LONG)
                    Update.updateLayout(0, 2, false)
                }
        }))
    }
    
    static func refreshAllUsers(){
        
        Async.run(Async.PRIORITY_INTERNETBIG, AsyncSyncSuccessInterface(runTask: {
            
            let array = try PFCloud.callFunction("getAllTimeUserList", withParameters: [:]) as! [String]
            
            let oldList = Local.readList(1, 0)
            
            for i in 0 ..< min(Local.readIndex(1, 0), oldList.count) {
                let item = oldList[i]
                if (!array[0..<min(20, array.count)].contains(item)) {
                    UserObject.unpinUserObjectSync(item)
                }
            }
            
            Local.writeIndex(1, 0, 0)
            Local.writeList(1, 0, array)
            Refresh.fetchNextItems(1, 0, 20)
            return true
            }, afterTask: {
                (success:Bool, message:String) in
                if (!success) {
                    Toast.makeText(ViewController.context, "Failed to refresh users hall of fame.", Toast.LENGTH_LONG)
                    Update.updateLayout(1, 0, false)
                }
        }))
    }
    
    static func refreshAllPosts(){
        Async.run(Async.PRIORITY_INTERNETBIG, AsyncSyncSuccessInterface(runTask: {
            
            let array = try PFCloud.callFunction("getAllTimeList", withParameters: [:]) as! [String]
            
            let oldList = Local.readList(1, 1)
            let allIndexedLists = Local.readAllOtherIndexedLists(1, 1)
            
            for i in 0 ..< min(Local.readIndex(1, 1), oldList.count) {
                let item = oldList[i]
                if (!array[0..<min(10, array.count)].contains(item) && !allIndexedLists.contains(item)) {
                    PostObject.unpinPostObjectSync(item)
                    
                    let commentsList = Local.readCommentsList(item, false)
                    for j in 0 ..< min(Local.readCommentsIndex(item, false), commentsList.count){
                        CommentObject.unpinCommentObjectSync(commentsList[j])
                    }
                    Local.writeCommentsIndex(item, false, 0)
                    Local.writeCommentsIndex(item, true, 0)
                }
            }
            
            Local.writeIndex(1, 1, 0)
            Local.writeList(1, 1, array)
            
            Refresh.fetchNextItems(1, 1, 10)
            return true
            }, afterTask: {
                (success:Bool, message:String) in
                if (!success) {
                    Toast.makeText(ViewController.context, "Failed to refresh posts hall of fame.", Toast.LENGTH_LONG)
                    Update.updateLayout(1, 1, false)
                }
        }))
    }
    
    static func refreshNotifications(){
        Async.run(Async.PRIORITY_INTERNETBIG, AsyncSyncSuccessInterface(runTask: {
            
            let query = PFQuery(className: "Notification")
            query.whereKey("userId", equalTo: CurrentUser.userId())
            query.addDescendingOrder("time")
            let objects = try query.findObjects()
            
            var array:[String] = []
            for object in objects{
                array.append(object.objectId!)
            }
            
            let oldList = Local.readList(2, 0)
            
            for i in 0 ..< min(Local.readIndex(2, 0), oldList.count) {
                let item = oldList[i]
                if (!array[0..<min(15, array.count)].contains(item)) {
                    NotificationObject.unpinNotificationObjectSync(item)
                }
            }
            
            Local.writeIndex(2, 0, 0)
            Local.writeList(2, 0, array)
            Refresh.fetchNextItems(2, 0, 15)
            return true
            }, afterTask: {
                (success:Bool, message:String) in
                if (!success) {
                    Toast.makeText(ViewController.context, "Failed to refresh notifications.", Toast.LENGTH_LONG)
                    Update.updateLayout(2, 0, false)
                }
        }))
    }
    
    static func refreshActivity(){
        Async.run(Async.PRIORITY_INTERNETBIG, AsyncSyncSuccessInterface(runTask: {
            
            let query = PFQuery(className: "Activity")
            query.whereKey("userId", equalTo: CurrentUser.userId())
            query.addDescendingOrder("time")
            let objects = try query.findObjects()
            
            var array:[String] = []
            for object in objects{
                array.append(object.objectId!)
            }
            
            let oldList = Local.readList(2, 1)
            
            for i in 0 ..< min(Local.readIndex(2, 1), oldList.count) {
                let item = oldList[i]
                if (!array[0..<min(15, array.count)].contains(item)) {
                    ActivityObject.unpinActivityObjectSync(item)
                }
            }
            
            Local.writeIndex(2, 1, 0)
            Local.writeList(2, 1, array)
            Refresh.fetchNextItems(2, 1, 15)
            return true
        }, afterTask: {
            (success:Bool, message:String) in
            if (!success) {
                Toast.makeText(ViewController.context, "Failed to refresh activity.", Toast.LENGTH_LONG)
                Update.updateLayout(2, 1, false)
            }
        }))
    }
    
    static func refreshCurrentUser(_ sortByUplifts:Bool){
        
        Async.run(Async.PRIORITY_INTERNETBIG, AsyncSyncSuccessInterface(runTask: {
            var map:[String : Any] = [:]
            map["sortByUplifts"] = sortByUplifts
            map["userId"] = CurrentUser.userId()
            
            let array = try PFCloud.callFunction("getUserPostList", withParameters: map) as! [String]
            
            let oldList = Local.readList(2, 1, sortByUplifts)
            let allIndexedLists = Local.readAllOtherIndexedLists(2, 1, sortByUplifts)
            
            for i in 0 ..< min(Local.readIndex(2, 1, sortByUplifts), oldList.count) {
                let item = oldList[i]
                if (!array[0..<min(10, array.count)].contains(item) && !allIndexedLists.contains(item)) {
                    PostObject.unpinPostObjectSync(item)
                    
                    let commentsList = Local.readCommentsList(item, false)
                    for j in 0 ..< min(Local.readCommentsIndex(item, false), commentsList.count){
                        CommentObject.unpinCommentObjectSync(commentsList[j])
                    }
                    Local.writeCommentsIndex(item, false, 0)
                    Local.writeCommentsIndex(item, true, 0)
                }
            }
            
            Local.writeIndex(2, 1, sortByUplifts, 0)
            Local.writeList(2, 1, sortByUplifts, array)
            
            Refresh.fetchNextItems(2, 1, sortByUplifts, 10)
            return true
            }, afterTask: {
                (success:Bool, message:String) in
                if (!success) {
                    Toast.makeText(ViewController.context, "Failed to refresh my posts.", Toast.LENGTH_LONG)
                    Update.updateLayout(2, 1, false)
                }
        }))
    }
    
    static func refreshSettings(){
        
        Async.run(Async.PRIORITY_INTERNETBIG, AsyncSyncSuccessInterface(runTask: {
            
            try CurrentUser.user().object.fetch().pin()
            
            let _ = CurrentUser.user().getThumb()
            
            try PFObject(withoutDataWithClassName: "Charity", objectId: CurrentUser.charity()).fetch().pin()
            
            try DataStore.refreshSync()
            
            return true
            
            }, afterTask: {
                (success:Bool, message:String) in
                if (!success) {
                    Toast.makeText(ViewController.context, "Failed to refresh settings.", Toast.LENGTH_LONG)
                }
                Update.updateLayout(3, 0, true)
        }))
    }
    
    static func refreshComments(_ sender:WindowWithComments, _ postId:String, _ sortByUplifts:Bool, _ commentId:String?){
        Async.run(Async.PRIORITY_INTERNETBIG, AsyncSyncSuccessInterface(runTask: {
            var map:[String : Any] = [:]
            map["sortByUplifts"] = sortByUplifts
            map["postId"] = postId
            let array = try PFCloud.callFunction("getCommentList", withParameters: map) as! [String]
            
            let oldList = Local.readCommentsList(postId, sortByUplifts)
            let otherList = Local.readCommentsList(postId, !sortByUplifts)
            
            for i in 0 ..< min(Local.readIndex(2, 1, sortByUplifts), oldList.count) {
                let item = oldList[i]
                if (!array[0..<min(10, array.count)].contains(item) && !otherList.contains(item)) {
                    CommentObject.unpinCommentObjectSync(item)
                }
            }
            
            Local.writeCommentsList(postId, sortByUplifts, array)
            Local.writeCommentsIndex(postId, sortByUplifts, 0)
            var numToFetch = 10
            if(commentId != nil){
                if(array.contains(commentId!)){
                    numToFetch = array.count - array.index(of: commentId!)!
                    sender.foundComment = true
                }else{
                    Async.toast("Unable to locate your comment.  It may no longer exist.", true)
                }
            }
            Refresh.fetchNextCommentItems(sender, postId, sortByUplifts, numToFetch)
            return true
            }, afterTask: {
                (success:Bool, message:String) in
                if (!success) {
                    Toast.makeText(ViewController.context, "Failed to refresh comments.", Toast.LENGTH_LONG)
                    Update.updateLayout(2, 1, false)
                }
        }))
    }
    
    static func refreshUser(_ sender:WindowWithUser, _ userObject:UserObject, _ sortByUplifts:Bool){
    
    let _ = sender.scroll.animate().translationY(RefreshView.refreshH).setDuration(300).setInterpolator(.decelerate);
    sender.refreshView.animateRefresh();
    
    let charityObject = CharityObject(obj: nil);
        
        Async.run(Async.PRIORITY_INTERNETBIG, AsyncSyncSuccessInterface(runTask: {
            try userObject.object.fetch();
            try charityObject.object = PFObject(withoutDataWithClassName: "Charity", objectId: userObject.getCharity()!).fetch()
            try charityObject.object!.pin();
            
            var map:[String : Any] = [:]
            map["sortByUplifts"] = sortByUplifts
            map["userId"] = userObject.object.objectId!
            
            sender.setPostArray(sortByUplifts: sortByUplifts, array: try PFCloud.callFunction("getUserPostList", withParameters: map) as! [String])
            sender.setIndex(sortByUplifts: sortByUplifts, index: 0);
            return true;
        }, afterTask: { success, message in
            if (!success) {
                Toast.makeText(ViewController.context, "Failed to refresh posts.", Toast.LENGTH_LONG)
                sender.populatePosts(fromTop: false);
            }else{
                sender.populateProfile(userObject: userObject, charityObject: charityObject);
                Refresh.fetchNextUserItems(sender, sortByUplifts, 10);
            }
        }))
    }
    
    static func fetchNextItems(_ mode:Int, _ submode:Int, _ numToFetch:Int) {
        fetchNextItems(mode, submode, false, numToFetch)
    }
    
    static func fetchNextItems(_ mode:Int, _ submode:Int, _ sortByUplifts:Bool, _ numToFetch:Int) {
        
        let index = Local.readIndex(mode, submode, sortByUplifts)
        
        if(ViewController.context.refreshing[Misc.modeToPage(mode, submode)] && index > 0){
            return
        }
        
        ViewController.context.reachedBottom[Misc.modeToPage(mode, submode)] = true
        
        Async.run(Async.PRIORITY_INTERNETBIG, AsyncSyncSuccessInterface(runTask: {
            let type = (mode == 1 && submode == 0) ? "_User" : (mode == 2 && submode == 0) ? "Notification" : (mode == 2 && submode == 1) ? "Activity" : "Post"
            let list = Local.readList(mode, submode, sortByUplifts)
            
            var numToFetch = numToFetch
            
            if(index + numToFetch >= list.count) {
                numToFetch = list.count - index
            }
            
            var fetchList:[PFObject] = []
            for i in index ..< index + numToFetch{
                fetchList.append(PFObject(withoutDataWithClassName: type, objectId: list[i]))
            }
            
            try PFObject.fetchAll(fetchList)
            try PFObject.pinAll(fetchList)
            
            if type == "Post"{
            for object in fetchList{
                let postObject = PostObject()
                postObject.object = object
                let _ = postObject.getThumbs()
            }
            }
            
            Local.writeIndex(mode, submode, sortByUplifts, index + numToFetch)
            
            return true
            }, afterTask: {
                (success:Bool, message:String) in
                if(!success){
                    Toast.makeText(ViewController.context, "Failed to load next posts.", Toast.LENGTH_SHORT)
                }
                
                if (!ViewController.context.refreshing[Misc.modeToPage(mode, submode)] || index <= 0) {
                    Update.updateLayout(mode, submode, index == 0)
                }
                
                ViewController.context.reachedBottom[Misc.modeToPage(mode, submode)] = false
        }))
    }
    
    static func fetchNextCommentItems(_ sender:WindowWithComments, _ postId:String, _ sortByUplifts:Bool, _ numToFetch:Int){
        Async.run(Async.PRIORITY_INTERNETBIG, AsyncSyncSuccessInterface(runTask: {
            
            let index = Local.readCommentsIndex(postId, sortByUplifts)
            let list = Local.readCommentsList(postId, sortByUplifts)
            
            var numToFetch = numToFetch
            
            if(index + numToFetch >= list.count) {
                numToFetch = list.count - index
            }
            
            var fetchList:[PFObject] = []
            for i in index ..< index + numToFetch{
                var comment:PFObject!
                if (sortByUplifts) {
                    comment = PFObject(withoutDataWithClassName: "Comment", objectId: list[i])
                } else {
                    comment = PFObject(withoutDataWithClassName: "Comment", objectId: list[list.count - index - numToFetch + i])
                }
                fetchList.append(comment)
            }
            
            try PFObject.fetchAll(fetchList)
            try PFObject.pinAll(fetchList)
            
            for object in fetchList{
                let commentObject = CommentObject()
                commentObject.object = object
                let _ = commentObject.getThumbs()
            }
            
            Local.writeCommentsIndex(postId, sortByUplifts, index + numToFetch)
            
            return true
            }, afterTask: {
                (success:Bool, message:String) in
                if(!success){
                    Toast.makeText(ViewController.context, "Failed to load comments.", Toast.LENGTH_SHORT)
                }
                
                sender.populate()
        }))
    }
    
    static func fetchNextUserItems(_ sender:WindowWithUser, _ sortByUplifts:Bool, _ numToFetch : Int){
    
    let index = sender.getIndex(sortByUplifts: sortByUplifts);
    
    if(sender.refreshing && index > 0){
    return;
    }
    
    sender.reachedBottom = true;
        
        Async.run(Async.PRIORITY_INTERNETBIG, AsyncSyncSuccessInterface(runTask: {
            let list = sender.getPostArray(sortByUplifts: sortByUplifts);
            
            var numToFetch = numToFetch
            
            if (index + numToFetch >= list.count) {
                numToFetch = list.count - index;
            }
            
            var fetchList:[PFObject] = []
            for i in index ..< index + numToFetch {
                fetchList.append(PFObject(withoutDataWithClassName: "Post", objectId: list[i]));
            }
            
            try PFObject.fetchAll(fetchList)
            try PFObject.pinAll(fetchList)
            
            sender.setIndex(sortByUplifts: sortByUplifts, index: index + numToFetch);
            
            return true;
        }, afterTask: { success, message in
            if (!success){
            Toast.makeText(ViewController.context, "Failed to load next posts.", Toast.LENGTH_SHORT)
            
            }else{
                if (!sender.refreshing || index <= 0) {
                    sender.populatePosts(fromTop: index == 0);
                }
                sender.reachedBottom = false;
            }
        }))
    }
}
