//
//  PostView.swift
//  Uplift
//
//  Created by Adam Cobb on 11/10/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class PostView: UIView {
    weak var context:ViewController! = ViewController.context
    
    var isComment = false;
    var flagged = false;
    var isCurrentUser = false;
    var header:HeaderView!
    var upliftView:UpliftView!
    var content:ContentView!
    var flagText:UILabelX!
    var numComments:UILabelX!
    var highlightLeft:UIView!, highlightRight:UIView!
    
    var postOrComment:PostOrCommentObject?
    var user:UserObject?
    
    required init(coder:NSCoder?){
        
        if coder == nil{
            super.init(frame: .zero)
        }else{
            super.init(coder: coder!)!
        }
    }
    
    convenience init(postId:String?, isComment:Bool, clickable:Bool){
        self.init(coder: nil)
        if let postId = postId{
            self.tag = Tag.getTag(postId)
        }
    self.backgroundColor = Color.WHITE
    
    self.isComment = isComment;
        
        LayoutParams.alignParentLeftRight(subview: self)
    
        header = HeaderView();
    addSubview(header);
        LayoutParams.alignParentTop(subview: header)
    
    content = ContentView(!clickable);
        addSubview(content)
        LayoutParams.alignParentLeft(subview: content)
        LayoutParams.stackVertical(topView: header, bottomView: content)
    if(isComment){
        LayoutParams.setEqualConstraint(view1: content, attribute1: .right, view2: self, attribute2: .right, margin: -68)
    }else{
        LayoutParams.alignParentRight(subview: content)
        }
    
    flagText = UILabelX()
        flagText.setInsets(UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
        flagText.textColor = Color.flagColor
        flagText.font = ViewController.typefaceM(14)
        addSubview(flagText);
        
        LayoutParams.setHeight(view: flagText, height: 32)
        LayoutParams.alignParentRight(subview: flagText)
    if(isComment) {
        LayoutParams.alignBottom(view1: flagText, view2: content)
    }else{
        LayoutParams.stackVertical(topView: content, bottomView: flagText)
    }
        
        LayoutParams.alignParentBottom(subview: flagText)
    
    if(!isComment) {
    
    numComments = UILabelX()
        numComments.setInsets(UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
        numComments.textColor = Color.commentsColor
        numComments.font = ViewController.typefaceM(14)
        addSubview(numComments);
        LayoutParams.setHeight(view: numComments, height: 32)
        LayoutParams.stackVertical(topView: content, bottomView: numComments)
        LayoutParams.alignParentLeft(subview: numComments)
    }
    
        if(postId == nil){
            return;
        }
        
        let postId:String = postId as String!
    
    if(clickable) {
    
    let cover = UIView()
        addSubview(cover);
        LayoutParams.alignParentLeftRight(subview: cover)
        LayoutParams.alignParentTopBottom(subview: cover)
        
        TouchController.setUniversalOnTouchListener(self, allowSpreadMovement: true, visibleView: cover, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
            let location1 = Misc.getLocationInViews(self);
            let location2 = Misc.getLocationInViews(self.context.layout_all)
            let _ = WindowWithComments(id: postId, post: self.postOrComment as! PostObject, user: self.user!, startTranslation: location1.y - location2.y);
        }))
    
    ContentCreator2.setUpSides(inView: self)
    }
    
        highlightLeft = UIView()
        addSubview(highlightLeft)
        LayoutParams.setWidth(view: highlightLeft, width: 4)
        LayoutParams.alignParentLeft(subview: highlightLeft)
        LayoutParams.alignParentTopBottom(subview: highlightLeft)
        
        highlightRight = UIView()
        addSubview(highlightRight)
        LayoutParams.setWidth(view: highlightRight, width: 4)
        LayoutParams.alignParentRight(subview: highlightRight)
        LayoutParams.alignParentTopBottom(subview: highlightRight)
        
        TouchController.setUniversalOnTouchListener(flagText, allowSpreadMovement: true, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
            if self.isCurrentUser{
                Dialog.showTextDialog(title: isComment ? "Delete Comment" : "Delete Post", text: "This action cannot be undone.", negativeText: "Cancel", positiveText: "Delete", positiveCallback: DialogCallback(execute: {
                    self.context.handleDelete(postId: postId, isComment: isComment, postOrComment: self.postOrComment!);
                    return true;
                }))
            } else if (self.flagged) {
    Dialog.showTextDialog(title: isComment ? "Comment" : "Post" + " Marked as UnUplifting", text: "If you no longer consider this content to be UnUplifting, click 'UnMark.'", negativeText: "Cancel", positiveText: "UnMark", positiveCallback: DialogCallback(execute: {
    self.context.handleFlag(postId: postId, flagged: false, isComment: isComment, postOrComment: self.postOrComment!);
    return true;
                }))
    } else {
    let layout = VerticalLinearLayout()
                layout.setInsets(UIEdgeInsets(top: 12, left: 16, bottom: 4, right: 16))
    
    let textView = UILabelX()
    textView.textAlignment = .center
    textView.text = "Please let us know if you find this content or the profile of the user who posted it to be offensive, inaccurate, misleading, hurtful, or just generally detracting from the Uplift environment.  We'll take a look at it, and if we agree, we'll take necessary action to ensure the content is permanently removed.\n\nIf you'd like to provide us with an explanation of why this content is not uplifting, please do so below.\n\nThanks for helping us keep Uplift uplifting!"
                textView.textColor = Color.BLACK
                textView.alpha = 0.5
                textView.font = ViewController.typefaceR(14)
    layout.addSubview(textView)
                LayoutParams.alignParentLeftRight(subview: textView)
    
    let explanation = LabeledEditText(label: "Explanation (Optional)", fadingLabel: false, textSize: 17, labelSize: 14, errorSize: 11);
    layout.addSubview(explanation, marginTop: 8)
                LayoutParams.alignParentLeftRight(subview: explanation)
    
                Dialog.showDialog(title: isComment ? "Mark Comment as UnUplifting" : "Mark Post as UnUplifting", contentView: layout, negativeText: "Cancel", positiveText: "Mark", positiveCallback: DialogCallback(execute:{
    Toast.makeText(self.context, "Thanks for your feedback.  We'll review this content as soon as we can.", Toast.LENGTH_LONG)
    self.context.handleFlag(postId: postId, flagged: true, isComment: isComment, postOrComment: self.postOrComment!);
    if(explanation.getText() != ""){
    Upload.submitFlagReasoning(postOrCommentId: postId, message: explanation.getText());
    }
    return true;
                }))
            }
        }))
    
    if(isComment){
    
        CommentObject.getCommentObject(postId, mustRefresh: false, callback: CommentCallback(success: { comment in
            UserObject.getUser(comment.getUserId()!, callback: UserCallback(success: {user in
                self.populate(postId: postId, userObject: user, postOrCommentObject: comment);
            }, error: { message in
                Toast.makeText(self.context, "Unable to load comment.", Toast.LENGTH_SHORT)
            }))
        }, error: {message in
            Toast.makeText(self.context, "Unable to load comment.", Toast.LENGTH_SHORT)
        }))
    }else{
        PostObject.getPostObject(postId, mustRefresh: false, callback: PostCallback(success: { post in
            UserObject.getUser(post.getUserId()!, callback: UserCallback(success: { user in
                self.populate(postId: postId, userObject: user, postOrCommentObject: post);
            }, error: { message in
                Toast.makeText(self.context, "Unable to load post.", Toast.LENGTH_LONG)
            }))
        }, error: { message in
            Toast.makeText(self.context, "Unable to load post.", Toast.LENGTH_LONG)
        }))
    }
    }
    
    func populate(postId:String?, userObject:UserObject?, postOrCommentObject:PostOrCommentObject){
    self.postOrComment = postOrCommentObject;
    self.user = userObject;
        
        Async.run(SyncInterface(runTask: {
            if(self.upliftView != nil){
                self.upliftView.removeFromSuperview()
            }
            
            self.upliftView = UpliftView(postId: postId, uplifts: self.postOrComment!.getUplifts(), upliftedInit: self.postOrComment!.getUplifted(), isComment: self.postOrComment is CommentObject);
            self.upliftView.parentW = (self.postOrComment is PostObject) ? self.context.screenWidth : self.context.screenWidth - 16;
            self.header.addSubview(self.upliftView);
            self.header.upliftView = self.upliftView;
            
            if self.user != nil{
            self.isCurrentUser = self.postOrComment!.getUserId() == CurrentUser.userId()
            self.header.populate(self.user!, self.postOrComment!.getLocation(), Misc.dateToTime(self.postOrComment!.getDate()));
            }
            
            self.flag(newflagged: self.postOrComment!.getFlagged())
            
            self.content.populate(postOrComment: self.postOrComment!, user: self.user);
            
            self.populateBottom(comments: (self.postOrComment is PostObject) ? (self.postOrComment as! PostObject).getComments() : -1);
        }))
    }
    
    func populateBottom(comments:Int){
    if (comments == 1) {
    numComments.text = String(comments) + " Comment"
    } else if(comments >= 0){
    numComments.text = String(comments) + " Comments"
    }
    }
    
    func flag(newflagged:Bool){
    
    if(isCurrentUser){
    if(isComment){
    flagText.text = "Delete"
    }else {
    flagText.text = "Delete Post"
    }
    return;
    }
    
    if(newflagged){
    if(isComment){
    flagText.text = "Marked"
    }else {
    flagText.text = "Marked as UnUplifting"
    }
    flagText.textColor = Color.flaggedColor
        highlightLeft.backgroundColor = Color.flaggedColor
    highlightRight.backgroundColor = Color.flaggedColor
    }else {
    if(isComment){
    flagText.text = "Mark"
    }else {
    flagText.text = "Mark Post as UnUplifting"
    }
    if(flagged){ //(previously flagged)
    flagText.textColor = Color.flagColor
    highlightLeft.backgroundColor = .clear
    highlightRight.backgroundColor = .clear
    }
    }
    flagged = newflagged;
    }
    
    func highlight(){
    highlightLeft.backgroundColor = Color.theme_light0_625
    highlightRight.backgroundColor = Color.theme_light0_625
    
    highlightLeft.alpha = 0
    highlightRight.alpha = 0
    let _ = highlightLeft.animate().alpha(1).setDuration(200).setStartDelay(500).setInterpolator(.accelerate);
    let _ = highlightRight.animate().alpha(1).setDuration(200).setStartDelay(500).setInterpolator(.accelerate);
}
}
