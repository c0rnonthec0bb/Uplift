//
//  WindowWithComments.swift
//  Uplift
//
//  Created by Adam Cobb on 9/25/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit
import Parse

class WindowWithComments : WindowBase {
    
    var scroll:UIScrollViewX!
    var linear:VerticalLinearLayout!
    var refreshView:RefreshView!
    var postView:PostView!
    var commentsView:VerticalLinearLayout!
    
    var composeView:ComposeView!
    var bottomShadow:UIView!
    
    var postId:String!
    
    var foundComment = false;
    var justCommented = false;
    var foundCommentView:PostView!
    
    var sortSwitch:SortSwitch!
    
    convenience init(id:String, post:PostObject, user:UserObject, startTranslation:CGFloat){
        self.init(id: id, post: post, user: user, startTranslation: startTranslation, commentId: nil);
    }
    
    init(id:String, post:PostObject, user:UserObject, startTranslation:CGFloat, commentId:String?){
        
        var commentId = commentId
        
        super.init()
        
        if(WindowBase.topShownWindow() != nil && WindowBase.topShownWindow() is WindowWithComments) {
            WindowBase.instances.remove(element: self);
            return;
        }
        
        postId = id;
        
        buildTitle("Post by " + user.getName()!);
        buildComments(postId: postId, post: post, user: user);
        buildFrame();
        
        if(commentId != nil && commentId == ""){
            postView.highlight();
            commentId = nil;
        }
        
        if(commentId != nil) {
            sortSwitch.byUplifts = false; //so that callback is not fired
            sortSwitch.setChoice(false);
            Toast.makeText(context, "Locating your comment.", Toast.LENGTH_SHORT)
        }
        
        Refresh.refreshComments(self, postId, self.sortSwitch.byUplifts, commentId);
        
        //instead of showFrame():
        
        shown = true;
        layout_windows.isHiddenX = false
        frame.isHiddenX = false
        frame.alpha = 0
        frame.translationY = startTranslation - topH - SortSwitch.H - (8 + 8)
        let _ = frame.animate().alpha(1).setStartDelay(0).setDuration(300).setInterpolator(.linear).setListener(AnimatorListener(onAnimationEnd: {
            self.showFrame();
        }))
    }
    
    func buildComments(postId:String, post:PostObject, user:UserObject) {
        
        let layout = UIView()
        layout.setInsets(UIEdgeInsets(top: -RefreshView.H, left: 0, bottom: 0, right: 0))
        
        scroll = UIScrollViewX()
        LayoutParams.alignParentLeftRight(subview: scroll)
        LayoutParams.alignParentTopBottom(subview: scroll, marginTop: 0, marginBottom: ComposeView.bottomH)
        scroll.backgroundColor = Color.main_background
        layout.addSubview(scroll);
        scroll.showsVerticalScrollIndicator = false
        TouchController.setUniversalOnTouchListener(scroll, allowSpreadMovement: true);
        
        linear = VerticalLinearLayout()
        LayoutParams.alignParentScrollVertical(subview: linear)
        scroll.addSubview(linear);
        
        refreshView = RefreshView();
        linear.addSubview(refreshView);
        
        sortSwitch = SortSwitch(comments: true, pageName: postId, callback: SortCallback(execute: { sortByUplifts in
            let commentsH = Measure.h(self.commentsView);
            self.commentsView.removeAllViews();
            
            let spinner = ProgressBar()
            LayoutParams.setWidthHeight(view: spinner, width: 50, height: 50)
            LayoutParams.centerParentHorizontal(subview: spinner)
            LayoutParams.alignParentTopBottom(subview: spinner, marginTop: 8, marginBottom: commentsH - (50 + 8))
            self.commentsView.addSubview(spinner);
            
            Refresh.refreshComments(self, postId, self.sortSwitch.byUplifts, nil);
        }))
        
        linear.addSubview(ContentCreator.divider());
        linear.addSubview(sortSwitch);
        linear.addSubview(ContentCreator.divider());
        
        postView = PostView(postId: postId, isComment: false, clickable: false);
        postView.populate(postId: postId, userObject: user, postOrCommentObject: post);
        postView.touchListener = nil
        linear.addSubview(postView);
        linear.addSubview(ContentCreator.shadow(top: true, alpha: 0.3));
        
        PostObject.getPostObject(postId, mustRefresh: false, callback: PostCallback(success: { post in
            UserObject.getUser(post.getUserId()!, callback: UserCallback(success: { user in
                post.object.fetchInBackground(block: { object, e in
                    if (e == nil) {
                        self.postView.populate(postId: postId, userObject: user, postOrCommentObject: post); //in case it has changed
                    }
                })
            }, error: { message in
                Toast.makeText(self.context, "Failed to load comments.", Toast.LENGTH_LONG)
            }))
        }, error: { message in
            Toast.makeText(self.context, "Failed to load comments.", Toast.LENGTH_LONG)
        }))
        
        commentsView = VerticalLinearLayout()
        LayoutParams.alignParentLeftRight(subview: commentsView, marginLeft: 8, marginRight: 8)
        linear.addSubview(commentsView);
        
        let spinner = ProgressBar()
        LayoutParams.setWidthHeight(view: spinner, width: 50, height: 50)
        LayoutParams.centerParentHorizontal(subview: spinner)
        LayoutParams.alignParentTopBottom(subview: spinner, marginTop: 8, marginBottom: 8)
        commentsView.addSubview(spinner);
        
        composeView = ComposeView(id: postId);
        LayoutParams.alignParentLeftRight(subview: composeView)
        linear.addSubview(composeView);
        
        bottomShadow = ContentCreator.shadow(top: false, alpha: 0.2);
        LayoutParams.alignParentBottom(subview: bottomShadow, margin: ComposeView.bottomH)
        LayoutParams.setHeight(view: bottomShadow, height: 6)
        layout.addSubview(bottomShadow);
        
        layout.addSubview(composeView.quickView);
        layout.addSubview(composeView.bottomView);
        
        TouchController.setUniversalOnTouchListener(composeView.quickMessage, allowSpreadMovement: false, whiteWhenOff: false, clickCallback: ClickCallback(execute:{
            self.scroll.scrollRectToVisible(CGRect(origin: CGPoint(x:0, y: self.composeView.y - RefreshView.refreshH), size: self.composeView.originalSize), animated: true)
        }))
        
        scroll.scrollChangedListeners.append({
            if (!self.shown) {
                return;
            }
            
            if (self.scroll.contentOffset.y >= self.composeView.y - self.scroll.height + self.composeView.textEdit.y + self.composeView.quickView.height + 6 /*due to margins*/) {
                if (self.composeView.quickEdit.isFirstResponder) {
                    let sel = self.composeView.quickEdit.editText.selectedTextRange;
                    self.composeView.textEdit.setFocused();
                    self.composeView.textEdit.editText.selectedTextRange = sel;
                }
                self.composeView.quickView.isHiddenX = true
                self.bottomShadow.translationY = 0
            } else {
                self.composeView.quickView.isHiddenX = false
                self.bottomShadow.translationY = -self.composeView.quickView.height
                if (self.composeView.textEdit.isFirstResponder) {
                    let sel = self.composeView.textEdit.editText.selectedTextRange;
                    self.composeView.quickEdit.setFocused();
                    self.composeView.quickEdit.editText.selectedTextRange = sel;
                }
            }
            
            if (self.scroll.contentOffset.y == self.linear.height - self.scroll.height) {
                self.bottomShadow.isHiddenX = true
            } else {
                self.bottomShadow.isHiddenX = false
            }
        })
        
        composeView.updateBottomCallback = UpdateCallback(execute: {
            var quickViewHidden = true;
            
            if(Measure.h(self.composeView.quickView) == 0){
                let _ = Measure.wrapH(self.composeView.quickView, width: self.context.screenWidth);
            }
            
            if (self.scroll.contentOffset.y < self.composeView.y - self.scroll.height + self.composeView.textEdit.y + Measure.h(self.composeView.quickView) + 6 /*due to margins*/) {
                quickViewHidden = false
            } //else invisible
            
            if(Measure.h(self.composeView) == 0){
                let _ = Measure.wrapH(self.composeView, width: self.context.screenWidth);
            }
            
            if(self.composeView.contentType == -1 && self.linear.height + (self.composeView.height == 0 || self.composeView.isHiddenX ? Measure.h(self.composeView) : 0) <= self.scroll.height){
                self.composeView.quickHeader.isHiddenX = false
                self.composeView.isHiddenX = true
                quickViewHidden = false
            }else{
                self.composeView.quickHeader.isHiddenX = true
                self.composeView.isHiddenX = false
            }
            
            self.composeView.quickView.isHiddenX = quickViewHidden
            
            Async.run(SyncInterface(runTask:{
                if (self.composeView.quickView.isHiddenX) {
                    self.bottomShadow.translationY = 0
                } else {
                    self.bottomShadow.translationY = -self.composeView.quickView.height
                }
            }))
        })
        
        Async.run(100, SyncInterface(runTask:{
            self.composeView.updateBottomCallback!.execute();
        }))
        
        composeView.newContentCallback = UpdateCallback(execute: {
            self.scroll.smoothScrollY(self.linear.height, durationInMillis: 400, delay: 200)
        })
        
        content = layout;
    }
    
    func populate(){
        let _ = scroll.animate().translationY(0).setDuration(200).setInterpolator(.decelerate);
        
        refreshView.setDefault();
        
        let newCommentsView = VerticalLinearLayout()
        LayoutParams.alignParentLeftRight(subview: newCommentsView)
        
        let _ = content.animate().translationY(0).setDuration(200).setInterpolator(.decelerate);
        
        let commentIndex = Local.readCommentsIndex(postId, sortSwitch.byUplifts);
        let commentList = Local.readCommentsList(postId, sortSwitch.byUplifts);
        
        if(!sortSwitch.byUplifts && commentIndex < commentList.count){
            newCommentsView.addSubview(loadMore(sortByUplifts: false)); //because of looper thing
        }
        
            for i in 0 ..< commentIndex {
                var commentView:PostView!
                if(self.sortSwitch.byUplifts){
                    commentView = PostView(postId: commentList[i], isComment: true, clickable: false);
                }else {
                    commentView = PostView(postId: commentList[commentList.count - commentIndex + i], isComment: true, clickable: false);
                }
                if(self.foundComment && i == 0){
                    self.foundCommentView = commentView;
                }
                newCommentsView.addSubview(commentView);
            }
        
            if(self.sortSwitch.byUplifts && commentIndex < commentList.count){
                newCommentsView.addSubview(self.loadMore(sortByUplifts: true)); //because of looper
            }
            
            self.commentsView.removeAllViews();
            self.commentsView.addSubview(newCommentsView);
            
            Async.run(SyncInterface(runTask:{
                //self.composeView.updateBottomCallback!.execute(); not necessary for iOS
                if(self.foundComment){
                    self.foundComment = false;
                    Toast.makeText(self.context, "Successfully located your comment!", Toast.LENGTH_SHORT)
                    UIView.animate(withDuration: 1000, delay: 0, options: .curveEaseInOut, animations: {
                        self.scroll.scrollRectToVisible(CGRect(x: 0, y: Misc.getLocationInViews(self.foundCommentView).y - self.topH - 100 + self.scroll.contentOffset.y, width: 1, height: 1), animated: false)
                    }, completion: nil)
                    
                    self.foundCommentView.highlight();
                }
                
                if(self.justCommented){
                    self.justCommented = false;
                    
                    UIView.animate(withDuration: 500, delay: 0, options: .curveEaseInOut, animations: {
                        self.scroll.scrollRectToVisible(CGRect(x: 0, y: Measure.wrapH(self.linear, width: self.context.screenWidth), width: 1, height: 1), animated: false)
                    }, completion: nil)
                }
            }))
    }
    
    func loadMore(sortByUplifts:Bool)->VerticalLinearLayout{
        let layout = VerticalLinearLayout()
        LayoutParams.alignParentLeftRight(subview: layout)
        
        let loadMore = UILabelX()
        LayoutParams.alignParentLeftRight(subview: loadMore)
        LayoutParams.setHeight(view: loadMore, height: 36)
        loadMore.textAlignment = .center
        loadMore.backgroundColor = Color.WHITE
        if(sortByUplifts){
            loadMore.text = "Load More Comments"
        }else{
            loadMore.text = "Load Previous Comments"
        }
        ContentCreator.setUpBoldThemeStyle(loadMore, size: 17, italics: true);
        
        let loadingSpinner = Update.loadingSpinner();
        
        if(sortByUplifts){
            layout.addSubview(loadingSpinner);
        }
        layout.addSubview(loadMore);
        if(!sortByUplifts){
            layout.addSubview(loadingSpinner);
        }
        
        loadingSpinner.isHiddenX = true
        
        TouchController.setUniversalOnTouchListener(loadMore, allowSpreadMovement: true, whiteWhenOff: true, clickCallback: ClickCallback(execute: {
            loadMore.touchListener = nil
            loadingSpinner.isHiddenX = false
            Refresh.fetchNextCommentItems(self, self.postId, sortByUplifts, 10);
        }))
        
        return layout;
    }
    
    var failedZeroScroll = false;
    
    override func scrollActionOnFalseMove(v:UIView, touches:[UITouch], deltay:CGFloat)->Bool{
        if(v != scroll && scroll.subviews.first!.height > scroll.height){
            return false;
        }
        
        if(scroll.contentOffset.y != 0 && scroll.contentOffset.y > -deltay){
            failedZeroScroll = true;
        }
        
        if (deltay >= 0 && scroll.contentOffset.y == 0 && !failedZeroScroll) {
            let refreshViewTrans:CGFloat = 30 * log((deltay) / 1 / 30 + 1);
            scroll.translationY = refreshViewTrans
            
            if (refreshViewTrans >= RefreshView.refreshH!) {
                refreshView.setPoised();
            } else {
                refreshView.setDefault();
            }
            if (scroll.contentOffset.y != 0) {
                scroll.contentOffset = .zero
            }
            return true;
        } else {
            scroll.translationY = 0
        }
        return false
    }
    
    override func scrollActionOnFalseUpCancel(v:UIView, touches:[UITouch], deltay:CGFloat)->Bool{
        if(v != scroll && scroll.subviews.first!.height > scroll.height){
            return false;
        }
        
        failedZeroScroll = false;
        if (scroll.translationY >= RefreshView.refreshH) {
            let _ = scroll.animate().translationY(RefreshView.refreshH).setDuration(300).setInterpolator(.decelerate);
            refreshView.animateRefresh();
            
            commentsView.removeAllViews();
            
            let spinner = ProgressBar()
            LayoutParams.setWidthHeight(view: spinner, width: 50, height: 58)
            LayoutParams.centerParentHorizontal(subview: spinner)
            commentsView.addSubview(spinner, marginTop: 8);
            
            PostObject.getPostObject(postId, mustRefresh: false, callback: PostCallback(success: {post in
                UserObject.getUser(post.getUserId()!, callback: UserCallback(success: { user in
                    post.object.fetchInBackground(block: { object, e in
                        self.postView.populate(postId: self.postId, userObject: user, postOrCommentObject: post)
                    })
                }, error: { message in
                    Toast.makeText(self.context, "Failed to load comments.", Toast.LENGTH_LONG)
                }))
            }, error: { message in
                Toast.makeText(self.context, "Failed to load comments.", Toast.LENGTH_LONG)
            }))
            
            Refresh.refreshComments(self, postId, sortSwitch.byUplifts, nil);
        } else {
            let _ = scroll.animate().translationY(0).setDuration(200).setInterpolator(.decelerate);
            refreshView.setDefault();
        }
        return false
    }
}

