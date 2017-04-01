//
//  NotificationView.swift
//  Uplift
//
//  Created by Adam Cobb on 12/29/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class NotificationView : UIView{
    weak var context:ViewController! = ViewController.context
    var message:UILabelX!
    var timeText:UILabelX!
    
    required init(coder:NSCoder?){
        
        if coder == nil{
            super.init(frame: .zero)
        }else{
            super.init(coder: coder!)!
        }
    }
    
    convenience init(){
        self.init(coder: nil)
        LayoutParams.alignParentLeftRight(subview: self)
    self.backgroundColor = Color.WHITE
    
    message = UILabelX()
        LayoutParams.alignParentLeftRight(subview: message)
        LayoutParams.alignParentTopBottom(subview: message, marginTop: 0, marginBottom: -20)
        message.setInsets(UIEdgeInsets(top: 12, left: 64, bottom: 12, right: 8))
    message.font = ViewController.typefaceR(17)
    self.addSubview(message);
    
    timeText = UILabelX()
        LayoutParams.alignParentLeft(subview: timeText)
        LayoutParams.centerParentVertical(subview: timeText)
        timeText.setInsets(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))
    timeText.font = ViewController.typefaceM(14)
        timeText.textColor = Color.timeColor
    self.addSubview(timeText);
        
        ContentCreator2.setUpSides(inView: self)
    }
    
    func populate(_ notification:NotificationObject){
    timeText.text = Misc.dateToTime(notification.getDate())
    
    var text = "";
    if(notification.getNumber() == 1){
    text = "<b>1 person</b>";
    if(notification.getType() < 4){
    text += " has";
    }
    }else {
    text = "<b>" + String(notification.getNumber()) + " people</b>";
    if(notification.getType() < 4){
    text += " have";
    }
    }
    switch (notification.getType()){
    case 1:
    text += " <b>uplifted</b> your post ";
    break;
    case 2:
    text += " <b>uplifted</b> your comment ";
    break;
    case 3:
    text += " <b>commented</b> on your post ";
    break;
    case 4:
    text += " <b>also commented</b> on the post ";
    break;
    default:break;
    }
    text += "<i>\"" + notification.getPreview()! + "\"</i>";
    
    if(!notification.isRead()){
    ContentCreator.setUpBoldThemeStyle(message, size: 17, italics: false);
        message.font = ViewController.typefaceR(17)
    }else{
    message.textColor = Color.halfBlack
        message.layer.shadowColor = UIColor.clear.cgColor
    }
        
        message.setTextFromHtml(text)
        
        TouchController.setUniversalOnTouchListener(self, allowSpreadMovement: true, whiteWhenOff: true, clickCallback: ClickCallback(execute: {
            self.loadPost(notification)
        }))
    }
    
    func loadPost(_ notification:NotificationObject){
        
        PostObject.getPostObject(notification.getPostId()!, mustRefresh: true, callback: PostCallback(success: { post in
            UserObject.getUser(post.getUserId()!, callback: UserCallback(success: { user in
                let _ = WindowWithComments(id: notification.getPostId()!, post: post, user: user, startTranslation: self.context.screenHeight, commentId: (notification.getType() == 2 || notification.getType() == 4 ? notification.getRootId() : ""));
                notification.setRead();
                self.populate(notification);
            }, error: { message in
                notification.setRead();
                self.populate(notification);
                Toast.makeText(self.context, "Unable to load notification.", Toast.LENGTH_SHORT)
            }))
        }, error: { message in
            notification.setRead();
            self.populate(notification);
            Toast.makeText(self.context, "Unable to load notification.  This item may no longer exist.", Toast.LENGTH_LONG)
        }))
    }
}
