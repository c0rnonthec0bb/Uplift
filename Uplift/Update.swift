//
//  Update.swift
//  Uplift
//
//  Created by Adam Cobb on 9/22/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit
import Parse

class Update{

    static weak var context:ViewController!

    static var postsShown:[Int] = [0, 0, 0, 0, 0, 0, 0, 0]

    static func updateLayout(_ mode:Int, _ submode:Int, _ fromTop:Bool) {
    updateLayout(mode, submode, fromTop, nil);
}

    static func updateLayout(_ mode:Int, _ submode:Int, _ fromTop:Bool, _ callback:UpdateCallback?){
    
    if(PFUser.current() == nil){
        LogIn.update();
        return;
    }
        
        Async.run(SyncInterface(runTask: {
            
        let _ = CurrentUser.thumb()
        
        let layoutNum = Misc.modeToPage(mode, submode);
        
        let layout = context.view_layouts[layoutNum];
        if (fromTop) {
            postsShown[layoutNum] = 0;
        }
        
        let sortSwitch = context.view_switches[layoutNum];
        
        let refreshView = context.view_refreshes[layoutNum];
        let index = Local.readIndex(mode, submode, sortSwitch.byUplifts);
        let list = Local.readList(mode, submode, sortSwitch.byUplifts);
        
        let reachedBottom = index >= list.count;
        switch (mode) {
        case 0:
            updateLayoutWithPosts(layoutNum: layoutNum, layout: layout, reachedBottom: reachedBottom, index: index, list: list, refreshView: refreshView, sortSwitch: sortSwitch, fromTop: postsShown[layoutNum] == 0, withAds: true, callback: callback);
            break;
        case 1:
            switch (submode) {
            case 0:
                updateAllTimeUsers(layoutNum: layoutNum, layout: layout, reachedBottom: reachedBottom, index: index, list: list, refreshView: refreshView, fromTop: postsShown[layoutNum] == 0, callback: callback);
                break;
            case 1:
                updateLayoutWithPosts(layoutNum: layoutNum, layout: layout, reachedBottom: reachedBottom, index: index, list: list, refreshView: refreshView, sortSwitch: sortSwitch, fromTop: postsShown[layoutNum] == 0, withAds: true, callback: callback);
                break;
            default:
                break;
            }
            break;
        case 2:
            switch (submode) {
            case 0:
                updateNotificationsLayout(layoutNum: layoutNum, layout: layout, reachedBottom: reachedBottom, index: index, list: list, refreshView: refreshView, fromTop: postsShown[layoutNum] == 0, callback: callback);
                break;
            case 1:
                updateActivityLayout(layoutNum: layoutNum, layout: layout, reachedBottom: reachedBottom, index: index, list: list, refreshView: refreshView, fromTop: postsShown[layoutNum] == 0, callback: callback);
                break;
            default:
                break;
            }
            break;
        case 3:
            updateSettingsLayout(layout: layout, refreshView: refreshView, callback: callback);
            break;
        default:
            break;
        }
        }))
    }
    
    static func done(_ layoutNum:Int, _ fromTop:Bool, _ callback:UpdateCallback?, _ reachedBottom:Bool){
        
        if fromTop{
            context.animate_all()
        }
        
        let _ = context.view_scrolls[layoutNum].animate().translationY(0).setDuration(200).setInterpolator(.decelerate).setListener(AnimatorListener(onAnimationEnd: {
            self.context.view_refreshes[layoutNum].setDefault()
        }));
        
        context.reachedBottom[layoutNum] = reachedBottom;
        
        context.refreshing[layoutNum] = false;
        
        if(Upload.postSent){
            if(layoutNum != 0){Refresh.refreshPage(0, 0);}
            if(layoutNum != 1){Refresh.refreshPage(0, 1);}
            if(layoutNum != 2){Refresh.refreshPage(0, 2);}
            if(layoutNum != 6){Refresh.refreshPage(2, 1);}
            Upload.postSent = false;
        }
        
        if(callback != nil) {
            callback!.execute();
        }
    }
    
    static func updateLayoutWithPosts(layoutNum:Int, layout:VerticalLinearLayout, reachedBottom:Bool, index:Int, list:[String], refreshView:RefreshView, sortSwitch:SortSwitch, fromTop:Bool, withAds:Bool, callback:UpdateCallback?){
        
        if (fromTop) {
            
            layout.removeAllViews();
            
            layout.addSubview(refreshView);
            
            LayoutParams.alignParentLeftRight(subview: refreshView)
            
            if (layoutNum != 4) {
                layout.addSubview(ContentCreator.divider());
                layout.addSubview(sortSwitch);
                LayoutParams.alignParentLeftRight(subview: sortSwitch)
            }
            
            layout.addSubview(ContentCreator.divider());
            layout.addSubview(ContentCreator.composeButton());
            
        } else {
            if let bottom = layout.viewWithTag(Tag.getTag("bottom")){
                bottom.removeFromSuperview()
            }
        }
    
        for i in stride(from: postsShown[layoutNum], to: min(index, list.count), by: 1){
    
    if(i % 8 == 2 && withAds){
    layout.addSubview(ContentCreator.divider());
    layout.addSubview(ContentCreator.adView());
    }
    
    layout.addSubview(ContentCreator.divider());
    layout.addSubview(PostView(postId: list[i], isComment: false, clickable: true));
    }
        
        if (reachedBottom) {
            layout.addSubview(BottomView(layoutNum: layoutNum, listEmpty: list.isEmpty));
        } else {
            layout.addSubview(loadingSpinner());
        }
            
            postsShown[layoutNum] = index;
            
            done(layoutNum, fromTop, callback, reachedBottom);
    }
    
    static func updateAllTimeUsers(layoutNum:Int, layout:VerticalLinearLayout, reachedBottom:Bool, index:Int, list:[String], refreshView:RefreshView, fromTop:Bool, callback:UpdateCallback?){
        
        if (fromTop) {
            layout.removeAllViews();
            layout.addSubview(refreshView);
            
            LayoutParams.alignParentLeftRight(subview: refreshView)
        } else {
            if let bottom = layout.viewWithTag(Tag.getTag("bottom")){
                bottom.removeFromSuperview()
            }
        }
        
        for i in stride(from: postsShown[layoutNum], to: min(index, list.count), by: 1){
    
    let rank = i + 1;
    
    layout.addSubview(ContentCreator.divider());
    
    let header = HeaderView();
    header.backgroundColor = Color.WHITE
    layout.addSubview(header);
            
            ContentCreator2.setUpSides(inView: header)
            
            UserObject.getUser(list[i], callback: UserCallback(success: { user in
                header.populate(user, "", nil);
                header.locationText.text = Misc.addSuffix(rank)
                header.locationText.font = ViewController.typefaceM(14)
                Layout.wrap(header.locationText, l: 50, t: 4);
                let amount = UILabelX()
                amount.textAlignment = .right
                amount.text = String(user.getUplifts()) + " uplifts"
                ContentCreator.setUpBoldThemeStyle(amount, size: 20, italics: true);
                header.addSubview(amount);
                Layout.wrapLeft(amount, r: context.screenWidth - 12, t: (Measure.w(header.nameText) > context.screenWidth - 216) ? 0 : 12);
            }, error: { message in
                Toast.makeText(context, "Unable to load user in place " + String(rank) + ".", Toast.LENGTH_SHORT)
            }))
    }
        
        if (reachedBottom) {
            layout.addSubview(BottomView(layoutNum: layoutNum, listEmpty: list.isEmpty));
        } else {
            layout.addSubview(loadingSpinner());
        }
        
            postsShown[layoutNum] = index;
            
            done(layoutNum, fromTop, callback, reachedBottom);
    }
    
    static func updateNotificationsLayout(layoutNum:Int, layout:VerticalLinearLayout, reachedBottom:Bool, index:Int, list:[String], refreshView:RefreshView, fromTop:Bool, callback:UpdateCallback?){
    
    if(context.currentMode == 2 && context.currentSubmode[2] == 0) {
    /*todo NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
    notificationManager.cancelAll();*/
    }
        
        if (fromTop) {
            layout.removeAllViews();
            
            layout.addSubview(refreshView);
            
            LayoutParams.alignParentLeftRight(subview: refreshView)
        } else {
            if let bottom = layout.viewWithTag(Tag.getTag("bottom")){
                bottom.removeFromSuperview()
            }
        }
        
        for i in stride(from: postsShown[layoutNum], to: min(index, list.count), by: 1){
    
    layout.addSubview(ContentCreator.divider());
    
    let view = NotificationView();
    layout.addSubview(view);
            
            NotificationObject.getNotificationObject(list[i], callback: NotificationCallback(success: { notification in
                view.populate(notification);
            }, error: { message in
                Toast.makeText(context, "Unable to load notification.", Toast.LENGTH_SHORT)
            }))
    }
        
        if (reachedBottom) {
            layout.addSubview(BottomView(layoutNum: layoutNum, listEmpty: list.isEmpty));
        } else {
            layout.addSubview(loadingSpinner());
        }
        
            postsShown[layoutNum] = index;
            
            done(layoutNum, fromTop, callback, reachedBottom);
    }
    
    static func updateActivityLayout(layoutNum:Int, layout:VerticalLinearLayout, reachedBottom:Bool, index:Int, list:[String], refreshView:RefreshView, fromTop:Bool, callback:UpdateCallback?){
        
        if (fromTop) {
            layout.removeAllViews();
            
            layout.addSubview(refreshView);
            
            LayoutParams.alignParentLeftRight(subview: refreshView)
        } else {
            if let bottom = layout.viewWithTag(Tag.getTag("bottom")){
                bottom.removeFromSuperview()
            }
        }
        
        for i in stride(from: postsShown[layoutNum], to: min(index, list.count), by: 1){
            
            layout.addSubview(ContentCreator.divider());
            
            let view = ActivityView();
            layout.addSubview(view);
            
            ActivityObject.getActivityObject(list[i], callback: ActivityCallback(success: { activity in
                view.populate(activity);
            }, error: { message in
                Toast.makeText(context, "Unable to load activity.", Toast.LENGTH_SHORT)
            }))
        }
        
        if (reachedBottom) {
            layout.addSubview(BottomView(layoutNum: layoutNum, listEmpty: list.isEmpty));
        } else {
            layout.addSubview(loadingSpinner());
        }
        
        postsShown[layoutNum] = index;
        
        done(layoutNum, fromTop, callback, reachedBottom);
    }
    
    static func updateSettingsLayout(layout:VerticalLinearLayout, refreshView:RefreshView, callback: UpdateCallback?){
        
        layout.removeAllViews();
        layout.addSubview(refreshView);
        
        LayoutParams.alignParentLeftRight(subview: refreshView)
    
    layout.addSubview(ContentCreator.divider());
    layout.addSubview(ContentCreator.infoLayout());
    layout.addSubview(ContentCreator.divider());
    layout.addSubview(ContentCreator.myCharityLayout());
    layout.addSubview(ContentCreator.divider());
    layout.addSubview(ContentCreator.statsLayout());
    layout.addSubview(ContentCreator.divider());
        layout.addSubview(ContentCreator.fullWidthButtonView(text: "Uplift Tutorial", callback: ClickCallback(execute: {
    TutorialController.startTutorial();
    })));
    layout.addSubview(ContentCreator.divider());
        layout.addSubview(ContentCreator.fullWidthButtonView(text: "Log Out", callback: ClickCallback(execute: {
            Dialog.showTextDialog(title: "Log Out of Uplift", text: "Are you sure you want to log out?", negativeText: "Cancel", positiveText: "Log Out", positiveCallback: DialogCallback(execute: {
                Toast.makeText(context, "Logging out..", Toast.LENGTH_LONG)
                PFUser.logOutInBackground(block: { e in
                    if LogIn.isLoggedIn(){
                        Toast.makeText(context, "Failed to log out of Uplift", Toast.LENGTH_LONG)
                    }else{
                        LogIn.update()
                    }
                })
                return true
            }))
        })))
        
        layout.addSubview(BottomView(layoutNum: 7, listEmpty: false));
            
            done(7, true, callback, true);
    }

    static func loadingSpinner()->UIView{
    
        let end = UIView()
        end.tag = Tag.getTag("bottom")
        LayoutParams.alignParentLeftRight(subview: end)
        end.backgroundColor = Color.main_background
        
        let spinner = ProgressBar()
        LayoutParams.setWidth(view: spinner, width: 50)
        LayoutParams.setHeight(view: spinner, height: 50)
        LayoutParams.alignParentTopBottom(subview: spinner)
        LayoutParams.centerParentHorizontal(subview: spinner)
        end.addSubview(spinner)
    
        return end;
    }
}
