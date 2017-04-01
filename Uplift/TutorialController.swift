//
//  TutorialController.swift
//  Uplift
//
//  Created by Adam Cobb on 12/14/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class TutorialController{
    static weak var context:ViewController!
    
    static var inited = false;
    
    static weak var layout_tutorial:UIView!
    static var blind:UIView!
    static var titleView:UILabelX!, bodyView:UILabelX!
    static var postView:PostView!
    static var buttonsLayout:BasicViewGroup!
    static var buttonLeft:UILabelX!, buttonCenter:UILabelX!, buttonRight:UILabelX!
    static var progressBar:UIView!
    
    static func initX(){
        layout_tutorial = context.layout_tutorial
        
        blind = UIView()
        blind.backgroundColor = Color.BLACK
        blind.alpha = 0.7
        layout_tutorial.addSubview(blind);
        Layout.exact(blind, width: context.screenWidth, height: context.screenHeight);
        
        titleView = UILabelX()
        titleView.touchListener = TouchListener(return: true)
        titleView.textColor = Color.theme_bold
        titleView.backgroundColor = Color.WHITE
        titleView.roundCorners(corners: [.allCorners], radius: 6)
        titleView.font = ViewController.typefaceM(context.screenHeight > 550 ? 24 : 20)
        titleView.textAlignment = .center
        titleView.setInsets(UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12))
        layout_tutorial.addSubview(titleView);
        
        bodyView = UILabelX()
        bodyView.touchListener = TouchListener(return: true)
        bodyView.textColor = Color.BLACK
        bodyView.backgroundColor = Color.WHITE
        bodyView.roundCorners(corners: [.allCorners], radius: 6)
        bodyView.font = ViewController.typefaceR(context.screenHeight > 550 ? 17 : 14)
        bodyView.textAlignment = .center
        bodyView.setInsets(UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))
        layout_tutorial.addSubview(bodyView);
        
        postView = PostView(postId: nil, isComment: false, clickable: false);
        postView.touchListener = TouchListener(return: true)
        layout_tutorial.addSubview(postView);
        
        buttonsLayout = BasicViewGroup();
        layout_tutorial.addSubview(buttonsLayout);
        Layout.exactUp(buttonsLayout, l: 0, b: context.screenHeight, width: context.screenWidth, height: 48 + 24);
        
        buttonCenter = UILabelX()
        buttonCenter.font = ViewController.typefaceMI(20)
        buttonCenter.textColor = Color.halfBlack
        buttonCenter.text = "Exit Tutorial"
        buttonCenter.backgroundColor = Color.WHITE
        buttonCenter.textAlignment = .center
        buttonsLayout.addSubview(buttonCenter);
        Layout.exact(buttonCenter, l: 0, t: 24, width: context.screenWidth, height: 48);
        
        buttonLeft = UILabelX()
        ContentCreator.setUpBoldThemeStyle(buttonLeft, size: 20, italics: true);
        buttonLeft.text = "Back"
        buttonLeft.setInsets(UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
        buttonLeft.backgroundColor = Color.WHITE
        buttonsLayout.addSubview(buttonLeft);
        Layout.wrapW(buttonLeft, l: 0, t: 24, height: 48);
        
        buttonRight = UILabelX()
        ContentCreator.setUpBoldThemeStyle(buttonRight, size: 20, italics: true);
        buttonRight.text = "Next"
        buttonRight.setInsets(UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
        buttonRight.backgroundColor = Color.WHITE
        buttonsLayout.addSubview(buttonRight);
        Layout.wrapWLeft(buttonRight, r: context.screenWidth, t: 24, height: 48);
        inited = true;
        
        layout_tutorial.touchListener = TouchListener(touchDown: {view, touches in
            self.endTutorial()
            return true
        }, touchMove: {view, touches in return true}, touchUpCancel: {up, view, touches in return true})
        
        TouchController.setUniversalOnTouchListener(buttonCenter, allowSpreadMovement: false, whiteWhenOff: true, clickCallback: ClickCallback(execute:{
            self.endTutorial()
        }))
        
        let progressBack = UIView()
        progressBack.backgroundColor = Color.theme_light0_5
        buttonsLayout.addSubview(progressBack);
        Layout.exact(progressBack, width: context.screenWidth, height: 24);
        
        progressBar = UIView()
        progressBar.backgroundColor = Color.theme_light0_75
        buttonsLayout.addSubview(progressBar);
        Layout.exact(progressBar, width: context.screenWidth, height: 24);
        
        for i in 0 ..< 10{
            
            let numView = UILabelX()
            numView.text = String(i + 1)
            numView.textColor = Color.WHITE
            numView.font = ViewController.typefaceB(11)
            numView.textAlignment = .center
            buttonsLayout.addSubview(numView);
            Layout.exact(numView, l: context.screenWidth * CGFloat(i) / 10, t: 0, width: context.screenWidth / 10, height: 24);
            
            TouchController.setUniversalOnTouchListener(numView, allowSpreadMovement: false, whiteWhenOff: false, clickCallback: ClickCallback(execute:{
                self.hideAndDisplayTutorial(i)
            }))
        }
    }
    
    
    static func hideAndDisplayTutorial(_ index:Int){
    
    let _ = bodyView.animate().alpha(0).translationYBy(50).setInterpolator(.accelerate).setDuration(500).setStartDelay(0);
    
        if !postView.isHiddenX{
            let _ = postView.animate().alpha(0).translationYBy(50).setInterpolator(.accelerate).setDuration(500).setStartDelay(250);
        }
    
        let _ = titleView.animate().alpha(0).translationYBy(50).setInterpolator(.accelerate).setDuration(500).setStartDelay(250 + (postView.isHiddenX ? 0 : 250)).setListener(AnimatorListener(onAnimationEnd: {
            self.displayTutorial(index);
        }))
    }
    
    static func displayTutorial(_ index:Int){
    
    postView.isHiddenX = true
    
    titleView.animate().cancel();
    postView.animate().cancel();
    bodyView.animate().cancel();
    
    titleView.alpha = 0
    postView.alpha = 0
    bodyView.alpha = 0
    
    titleView.translationY = 0
    postView.translationY = 0
    bodyView.translationY = 0
        
        var blindDelay:Int64 = 0, modeDelay:Int64 = 0, titleDelay:Int64 = 0
        var blindTranslation:CGFloat = 0
        var title:String!
        var body:String!
    
    switch (index) {
    //into located at bottom as 'default'
    case 1: // content
    context.currentMode = 3;
    blindTranslation = 0;
    blindDelay = 0;
    modeDelay = 0;
    titleDelay = 0;
    title = "Content on Uplift";
    body = "A post on Uplift looks like this." +
    "\n\n" +
    "If you like a post, you can 'uplift' it by tapping the arrow in the top right corner (give it a try!)." +
    "\n\n" +
    "If you find a post not uplifting, you can alert us by flagging it as spam." +
    "\n\n" +
    "Clicking on a post enables you to view comments on it and write your own.";
    postView.isHiddenX = false
    let postObject = PostObject()
    postObject.setComments(42);
    postObject.setText("A life is not important except in the impact it has on other lives.");
    postObject.setContentType(-1);
    postObject.setUplifters([]);
    postObject.setUplifts(26623);
    postObject.setFlaggers([]);
    
    postView.populate(postId: nil, userObject: nil, postOrCommentObject: postObject);
    
    Async.run(SyncInterface(runTask: {
        self.postView.header.populate("Jackie Robinson", Misc.encodeImage(#imageLiteral(resourceName: "robinson_prof")), [288, 288], "New York City, NY, USA", "Apr 15, 1947");
    }))
    
    break;
    case 2: //menu bar
    context.currentMode = 3;
    blindTranslation = context.menuH;
    blindDelay = 250;
    modeDelay = 0;
    titleDelay = 1500;
    title = "Navigation";
    body = "There are four sections of the app accessible from the green upper menu bar (shown above).  We will introduce them in the following four steps of this tutorial." +
    "\n\n" +
    "Tapping on the menu bar or dragging left and right on the screen enable you to navigate between them.  The gray triangle indicates which section is currently being shown.  For example, right now the rightmost section (the gear icon) is being shown.";
    break;
    case 3: // posts section
    context.currentMode = 0;
    blindTranslation = context.menuH + context.titleH;
    blindDelay = 250;
    modeDelay = 1250;
    titleDelay = 2500;
    title = "Posts";
    body = "The leftmost section contains recent posts on Uplift.  As shown, there are three subsections:" +
    "\n\n" +
    "The Local feed contains recent posts from within 5 miles (8 km) of your current location." +
    "\n\n" +
    "The Regional feed contains recent posts from within 400 miles (640 km)." +
    "\n\n" +
    "The Global feed contains recent posts from all over the world.";
    break;
    case 4: // hall of fame
    context.currentMode = 1;
    blindTranslation = context.menuH + context.titleH;
    blindDelay = 0;
    modeDelay = 500;
    titleDelay = 1500;
    title = "Hall of Fame";
    body = "The second section contains the best of Uplift and can serve as an inspiration for your own content.  It has two subsections:" +
    "\n\n" +
    "The Users subsection contains a list of the Users who have accumulated the most amount of total uplifts across all of their posts." +
    "\n\n" +
    "The Posts subsection contains the individual posts that have gotten the most uplifts since the release of Uplift.";
    break;
    case 5: // your stuff
    context.currentMode = 2;
    blindTranslation = context.menuH + context.titleH;
    blindDelay = 0;
    modeDelay = 500;
    titleDelay = 1500;
    title = "Your Stuff";
    body = "The third section is unique for each user, and again has two subsections:" +
    "\n\n" +
    "The Notifications subsection is updated every time someone uplifts or comments on (or after) one of your posts (or comments).  When you have unread notifications you will also receive a condensed alert in your phone's top notifications tray." +
    "\n\n" +
    "The Activity subsection contains all of the public actions you've taken on Uplift.";
    break;
    case 6: // options
    context.currentMode = 3;
    blindTranslation = context.menuH + context.titleH;
    blindDelay = 0;
    modeDelay = 500;
    titleDelay = 1500;
    title = "Options and Charities";
    body = "The rightmost section allows you to change parts of your profile and view your statistics on Uplift." +
    "\n\n" +
    "One important part of Uplift's mission to promote positivity is that every time someone else uplifts one of your posts, we donate a small amount of money to a charity of your choice.  You can view the available charities and choose your charity in the Options section as well.";
    break;
    case 7: // sort switch
    context.currentMode = 0;
    blindTranslation = context.menuH + context.titleH + 8 + SortSwitch.H;
    blindDelay = 1000;
    modeDelay = 500;
    titleDelay = 2250;
    title = "The Sort Switch";
    body = "Excluding the Hall of Fame, every page with posts or comments can be sorted either by Most Recent or Most Uplifted using a switch (shown above)." +
    "\n\n" +
    "A simple slide or tap on the switch enables you to view either the newest or best content on the feed.";
    context.view_scrolls[0].setContentOffset(.zero, animated: false)
    break;
    case 8: // share button
    context.currentMode = 0;
    blindTranslation = context.menuH + context.titleH + 16 + SortSwitch.H + HeaderView.H;
    blindDelay = 500;
    modeDelay = 0;
    titleDelay = 1750;
    title = "The Share Button";
    body = "Every page with posts also contains the option to share your own content." +
    "\n\n" +
    "Note that there is no difference between the share buttons on each feed.  Every post on Uplift is public to the world, but will start out being more visible on users' Local feeds.  As a post receives more uplifts, it moves higher on users' 'Most Uplifted' feeds and possibly eventually the Posts Hall of Fame.";
    context.view_scrolls[0].setContentOffset(.zero, animated: false)
    break;
    case 9: // the end
    context.currentMode = 3;
    blindTranslation = context.menuH + context.titleH;
    blindDelay = 0;
    modeDelay = 500;
    titleDelay = 1250;
    title = "Happy Uplifting!";
    body = "This concludes the Uplift tutorial.  At any time if you have questions or comments about the app, feel free to contact us via the bottom of the Options section.";
    context.view_scrolls[7].setContentOffset(CGPoint(x: 0, y: context.view_layouts[7].height - context.view_scrolls[7].height), animated: false)
    break;
    default: // intro
        context.currentMode = 3;
        blindDelay = 0;
        modeDelay = 0;
        titleDelay = 300;
        blindTranslation = 0;
        title = "A Tutorial of The Social Network Built on Positivity";
        body = "Members of Uplift such as yourself are committed to improving others' lives through the promotion of cheerfulness, community, and charity, and we've designed our platform accordingly." +
            "\n\n" +
            "We hope this tutorial enables you to use Uplift to its full potential." +
            "\n\n" +
        "Click 'Next' below to continue.";
        break;
    }
    
    if(index > 0) {
    let _ = buttonLeft.animate().translationY(0).setDuration(600).setInterpolator(.decelerate);
        TouchController.setUniversalOnTouchListener(buttonLeft, allowSpreadMovement: false, whiteWhenOff: true, clickCallback: ClickCallback(execute: {
            self.hideAndDisplayTutorial(index - 1);
        }))
    }else{
    let _ = buttonLeft.animate().translationY(48).setDuration(600).setInterpolator(.decelerate);
        }
        
        
        if(index < 9) {
            let _ = buttonRight.animate().translationY(0).setDuration(600).setInterpolator(.decelerate);
            TouchController.setUniversalOnTouchListener(buttonRight, allowSpreadMovement: false, whiteWhenOff: true, clickCallback: ClickCallback(execute: {
                self.hideAndDisplayTutorial(index + 1);
            }))
        }else{
            let _ = buttonRight.animate().translationY(48).setDuration(600).setInterpolator(.decelerate);
        }
    
    titleView.text = title
    bodyView.text = body
    
    let _ = blind.animate().setDuration(1000).setStartDelay(blindDelay).translationY(blindTranslation).setInterpolator(.accelerateDecelerate);
    
        Async.run(modeDelay, SyncInterface(runTask:{
            self.context.currentSubmode[self.context.currentMode] = 0;
            self.context.animate_all();
        }))
        
        Async.run(titleDelay, SyncInterface(runTask:{
            let _ = progressBar.animate().translationX(context.screenWidth * CGFloat(index - 9) / 10).setDuration(1000).setInterpolator(.accelerateDecelerate);
            
            Layout.wrapH(titleView, l: 12, t: blindTranslation + 16, width: context.screenWidth - 24);
            
            titleView.scaleX = 1.1
            titleView.scaleY = 1.1
            
            let _ = titleView.animate().alpha(1).scaleX(1).scaleY(1).setInterpolator(.decelerate).setDuration(500).setStartDelay(0).setListener(nil);
            
            if !postView.isHiddenX {
                
                Layout.wrapH(postView, l: 0, t: blindTranslation + Measure.h(titleView) + 16 + 8, width: context.screenWidth);
                layout_tutorial.layoutSubviews()
                
                postView.scaleX = 1.1
                postView.scaleY = 1.1
                
                let _ = postView.animate().alpha(1).scaleX(1).scaleY(1).setInterpolator(.decelerate).setDuration(500).setStartDelay(250);
            }
            
            Layout.wrapH(bodyView, l: 12, t: blindTranslation + Measure.h(titleView) + 16 + 8 + (postView.isHiddenX ? 0 : postView.height + 8), width: context.screenWidth - 24);
            
            bodyView.scaleX = 1.1
            bodyView.scaleY = 1.1
            
            let _ = bodyView.animate().alpha(1).scaleX(1).scaleY(1).setInterpolator(.decelerate).setDuration(500).setStartDelay(250 + (postView.isHiddenX ? 0 : 250));
            
            layout_tutorial.layoutSubviews()
            
            ViewHelper.onDidLayoutSubviews[titleView]!()
            ViewHelper.onDidLayoutSubviews[bodyView]!()
        }))

}

static func startTutorial(){
    if(!inited){
        initX();
    }
    
    titleView.alpha = 0
    postView.alpha = 0
    bodyView.alpha = 0
    
    progressBar.translationX = -context.screenWidth
    
    layout_tutorial.animate().cancel();
    
    layout_tutorial.alpha = 0
    layout_tutorial.translationY = 0
    layout_tutorial.isHiddenX = false
    
    buttonsLayout.animate().cancel();
    
    buttonsLayout.translationY = 48
    buttonRight.translationY = 48
    
    let _ = buttonsLayout.animate().translationY(0).setDuration(600).setStartDelay(300).setInterpolator(.decelerate);
    let _ = layout_tutorial.animate().alpha(1).setDuration(400).setInterpolator(.linear).setListener(AnimatorListener(onAnimationEnd: {
        self.displayTutorial(0);
    }))
}

static func endTutorial(){
    
    let _ = buttonsLayout.animate().translationY(48 - context.screenHeight).setDuration(500).setStartDelay(0).setInterpolator(.accelerate);
    let _ = layout_tutorial.animate().translationY(context.screenHeight).alpha(0).setDuration(500).setInterpolator(.accelerate).setListener(AnimatorListener(onAnimationEnd: {
        self.layout_tutorial.isHiddenX = true
    }))
}
}
