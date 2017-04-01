//
//  Callback.swift
//  Uplift
//
//  Created by Adam Cobb on 9/5/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class ClickCallback{
    var execute:()->Void
    
    init(execute:@escaping ()->Void){
        self.execute = execute
    }
}

class OnOffCallback{
    var on:()->Void
    var off:()->Void
    
    init(on:@escaping ()->Void, off:@escaping ()->Void){
        self.on = on
        self.off = off
    }
}

class UpdateCallback{
    var execute:()->Void
    
    init(execute:@escaping ()->Void){
        self.execute = execute
    }
}

class RefreshCallback{
    var success:()->Void
    var error:(_ message:String)->Void
    
    init(success:@escaping ()->Void, error:@escaping (_ message:String)->Void){
        self.success = success
        self.error = error
    }
}

class CharityCallback{
    var success:(_ charity:CharityObject)->Void
    var error:(_ message:String)->Void
    
    init(success:@escaping (_ charity:CharityObject)->Void, error:@escaping (_ message:String)->Void){
        self.success = success
        self.error = error
    }
}

class PostCallback{
    var success:(_ post:PostObject)->Void
    var error:(_ message:String)->Void
    
    init(success:@escaping (_ post:PostObject)->Void, error:@escaping (_ message:String)->Void){
        self.success = success
        self.error = error
    }
}

class CommentCallback{
    var success:(_ comment:CommentObject)->Void
    var error:(_ message:String)->Void
    
    init(success:@escaping (_ comment:CommentObject)->Void, error:@escaping (_ message:String)->Void){
        self.success = success
        self.error = error
    }
}

class UserCallback{
    var success:(_ user:UserObject)->Void
    var error:(_ message:String)->Void
    
    init(success:@escaping (_ user:UserObject)->Void, error:@escaping (_ message:String)->Void){
        self.success = success
        self.error = error
    }
}

class NotificationCallback{
    var success:(_ notification:NotificationObject)->Void
    var error:(_ message:String)->Void
    
    init(success:@escaping (_ notification:NotificationObject)->Void, error:@escaping (_ message:String)->Void){
        self.success = success
        self.error = error
    }
}

class ActivityCallback{
    var success:(_ activity:ActivityObject)->Void
    var error:(_ message:String)->Void
    
    init(success:@escaping (_ activity:ActivityObject)->Void, error:@escaping (_ message:String)->Void){
        self.success = success
        self.error = error
    }
}

class PictureIntentCallback{
    var success:(_ image:UIImage)->Void
    
    init(success:@escaping (_ image:UIImage)->Void){
        self.success = success
    }
}

class VideoIntentCallback{
    var success:(_ i:Int)->Void
    
    init(success:@escaping (_ i:Int)->Void){
        self.success = success
    }
}

class PreSendCallback{
    var execute:()->Bool
    var onDestroy:()->Void
    
    init(execute:@escaping ()->Bool, onDestroy:@escaping ()->Void){
        self.execute = execute
        self.onDestroy = onDestroy
    }
}

class SendCallback{
    var pinned:()->Void
    var sent:()->Void
    var failed:()->Void
    
    init(pinned:@escaping ()->Void, sent:@escaping ()->Void, failed:@escaping ()->Void){
        self.sent = sent
        self.pinned = pinned
        self.failed = failed
    }
}

class ImagePinchCallback{
    var dragX:(_ dx:CGFloat)->Bool
    var dragUp:(_ dx:CGFloat)->Bool
    
    init(dragX:@escaping (_ dx:CGFloat)->Bool, dragUp:@escaping (_ dx:CGFloat)->Bool){
        self.dragX = dragX
        self.dragUp = dragUp
    }
}

class SortCallback{
    var execute:(_ sortByUplifts:Bool)->Void
    
    init(execute:@escaping (_ sortByUplifts:Bool)->Void){
        self.execute = execute
    }
}

class GetImagesCallback{
    var executeSync:()->[Data]
    
    init(executeSync:@escaping ()->[Data]){
        self.executeSync = executeSync
    }
}
