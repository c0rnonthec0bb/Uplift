//
//  Upload.swift
//  Uplift
//
//  Created by Adam Cobb on 9/25/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import Foundation
import Parse

class Upload{
    static func sendPostOrComment(_ postOrCommentObject:PostOrCommentObject, _ text:String, _ contentType:Int, _ contentTitle:[String], _ contentText:[String], _ media:[Data], _ mediaDimens:[[Int]],  _ thumbs:[Data], _ thumbsDimens:[[Int]], _ callback:SendCallback){
        
        Async.run(Async.PRIORITY_IMPORTANT, AsyncSyncSuccessInterface(runTask: {
            
            postOrCommentObject.setUserId(CurrentUser.userId())
            postOrCommentObject.setLocation(Files.readString("location", "Unknown Location, Antarctica"))
            postOrCommentObject.setGeoPoint(Local.getCurrentGeoPoint())
            postOrCommentObject.setText(text)
            postOrCommentObject.setContentType(contentType)
            postOrCommentObject.setContentTitle(contentTitle)
            postOrCommentObject.setContentText(contentText)
            postOrCommentObject.setMediaDimens(mediaDimens)
            postOrCommentObject.setThumbsDimens(thumbsDimens)
            postOrCommentObject.setUplifters([""]) //apparently this is necessary
            postOrCommentObject.setUplifts(0)
            postOrCommentObject.setFlaggers([""])
            postOrCommentObject.object["justCreated"] = true
            
            var mediaFiles:[PFFile] = []
            for i in 0 ..< media.count{
                let file = PFFile(name: "media" + Misc.contentTypeExtension(contentType), data: media[i])!
                print("1")
                try file.save()
                print("2")
                mediaFiles.append(file)
            }
            
            postOrCommentObject.setMedia(mediaFiles)
            
            var thumbsFiles:[PFFile] = []
            for i in 0 ..< thumbs.count{
                let file = PFFile(name: "thumb" + Misc.contentTypeExtension(contentType), data: thumbs[i])!
                try file.save()
                thumbsFiles.append(file)
            }
            
            postOrCommentObject.setThumbs(thumbsFiles)
            
            try postOrCommentObject.object.save()
            try postOrCommentObject.object.pin()
            
            return true
            
            }, afterTask: {
                (success, message) in
                if (success) {
                    callback.sent()
                }else{
                    print("upload error: " + message)
                    callback.failed()
                }
        }))
    }
    
    static var postSent = false
    
    static func sendPost(_ text:String, _ contentType:Int, _ contentTitle:[String], _ contentText:[String], _ media:[Data], _ mediaDimens:[[Int]],  _ thumbs:[Data], _ thumbsDimens:[[Int]]){
        
        let modeSentOn = ViewController.context.currentModeRatio()
        
        let _ = ViewController.context.view_scrolls[modeSentOn].animate().translationY(50).setDuration(300).setInterpolator(.decelerate)
        ViewController.context.view_refreshes[modeSentOn].animateRefresh()
        
        let postObject = PostObject()
        postObject.setComments(0)
        sendPostOrComment(postObject, text, contentType, contentTitle, contentText, media, mediaDimens, thumbs, thumbsDimens, SendCallback(pinned: {
            }, sent: {
                postSent = true
                if(ViewController.context.view_switches[modeSentOn].byUplifts) {
                    ViewController.context.view_switches[modeSentOn].animateChoice(false)
                }else {
                    Refresh.refreshPage(Misc.pageToModes(modeSentOn)[0], Misc.pageToModes(modeSentOn)[1])
                }
                
            }, failed: {
                Update.done(modeSentOn, true, nil, ViewController.context.reachedBottom[modeSentOn])
                Toast.makeText(ViewController.context, "Failed to upload new post, please try again.", Toast.LENGTH_LONG)
        }))
    }
    
    static func sendComment(_ postId:String, _ text:String, _ contentType:Int, _ contentTitle:[String], _ contentText:[String], _ media:[Data], _ mediaDimens:[[Int]],  _ thumbs:[Data], _ thumbsDimens:[[Int]]){
        let sender = WindowBase.topShownWindow() as! WindowWithComments
        
        let loadingSpinner = Update.loadingSpinner()
        sender.commentsView.addSubview(loadingSpinner)
        LayoutParams.alignLeftRight(view1: sender.commentsView, view2: loadingSpinner)
        
        let commentObject = CommentObject()
        commentObject.setParentId(postId)
        sendPostOrComment(commentObject, text, contentType, contentTitle, contentText, media, mediaDimens, thumbs, thumbsDimens, SendCallback(pinned: {
            Async.run(SyncInterface(runTask: {
                var comments = Local.readCommentsList(postId, sender.sortSwitch.byUplifts)
                comments.append(commentObject.object.objectId!)
                Local.writeCommentsList(postId, sender.sortSwitch.byUplifts, comments)
                Local.writeCommentsIndex(postId, sender.sortSwitch.byUplifts, Local.readCommentsIndex(postId, sender.sortSwitch.byUplifts) + 1)
                for subview in sender.commentsView.subviews{
                    subview.removeFromSuperview()
                }
                
                let spinner = UIActivityIndicatorView()
                LayoutParams.setWidth(view: spinner, width: 50 - 2 * 8)
                LayoutParams.setHeight(view: spinner, height: 50 - 2 * 8)
                sender.commentsView.addSubview(spinner)
                LayoutParams.centerParentHorizontal(subview: sender.commentsView)
                
                sender.populate()
            }))
            }, sent: {
                Refresh.refreshComments(sender, postId, sender.sortSwitch.byUplifts, nil)
            }, failed: {
                Toast.makeText(ViewController.context, "Failed to upload new comment, please try again.", Toast.LENGTH_LONG)
        }))
    }
    
    static func submitNewName(_ name:String){
        let object = PFObject(className: "NewNameRequest")
        object["userId"] = CurrentUser.userId()
        object["newName"] = name
        object.saveEventually()
        
        Toast.makeText(ViewController.context, "Your request will be reviewed.", Toast.LENGTH_SHORT)
    }
    
    static func submitFlagReasoning(postOrCommentId:String, message:String){
        let object = PFObject(className: "FlagReasoning")
        object["userId"] = CurrentUser.userId()
        object["postOrCommentId"] = postOrCommentId
        object["message"] = message
        object.saveEventually();
    }
}
