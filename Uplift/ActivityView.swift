//
//  ActivityView.swift
//  Uplift
//
//  Created by Adam Cobb on 2/11/17.
//  Copyright © 2017 Adam Cobb. All rights reserved.
//

import UIKit

class ActivityView : UIView{
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
        message.textColor = Color.halfBlack
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
    
    func populate(_ activity:ActivityObject){
        timeText.text = Misc.dateToTime(activity.getDate())
        
        var text = "You "
        switch (activity.getType()){
        case 1:
            text += "<b>uplifted</b> " + activity.getOwnerName()! + "'s post ";
            break;
        case 2:
            text += "<b>uplifted</b> " + activity.getOwnerName()! + "'s comment ";
            break;
        case 3:
            text += "<b>posted</b> ";
            break;
        case 4:
            text += "<b>commented</b> ";
            break;
        default:break;
        }
        text += "<i>\"" + activity.getPreview()! + "\"</i>";
        
        message.setTextFromHtml(text)
        
        TouchController.setUniversalOnTouchListener(self, allowSpreadMovement: true, whiteWhenOff: true, clickCallback: ClickCallback(execute: {
            self.loadPost(activity)
        }))
    }
    
    func loadPost(_ activity:ActivityObject){
        
        PostObject.getPostObject(activity.getPostId()!, mustRefresh: true, callback: PostCallback(success: { post in
            UserObject.getUser(post.getUserId()!, callback: UserCallback(success: { user in
                let _ = WindowWithComments(id: activity.getPostId()!, post: post, user: user, startTranslation: self.context.screenHeight, commentId: (activity.getType() == 2 || activity.getType() == 4 ? activity.getRootId() : ""));
                self.populate(activity);
            }, error: { message in
                self.populate(activity);
                Toast.makeText(self.context, "Unable to load activity.", Toast.LENGTH_SHORT)
            }))
        }, error: { message in
            self.populate(activity);
            Toast.makeText(self.context, "Unable to load activity.  This item may no longer exist.", Toast.LENGTH_LONG)
        }))
    }
}
