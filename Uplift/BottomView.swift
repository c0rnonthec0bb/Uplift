//
//  BottomView.swift
//  Uplift
//
//  Created by Adam Cobb on 11/30/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit
import MessageUI

class BottomView : VerticalLinearLayout, MFMailComposeViewControllerDelegate{
    weak var context:ViewController! = ViewController.context
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    convenience init(layoutNum:Int, listEmpty:Bool){
        self.init(coder:nil)
    
        self.tag = Tag.getTag("bottom")
        LayoutParams.alignParentLeftRight(subview: self)
    
    var title = "";
    var text = "";
    var button1 = layoutNum == 7 ? "Contact Us" : "Share Something";
    var button2 = "";
    
    switch (layoutNum){
    case 0, 1, 2, 3, 4, 5, 6:
    switch (layoutNum) {
    case 0:
    button2 = "Go to Regional Feed";
    break;
    case 1:
    button2 = "Go to Global Feed";
    break;
    case 2:
    button2 = "Close Uplift for Now";
    break;
    default: break;
    }
    
    if !listEmpty{
    title = "That's All Folks!";
    switch (layoutNum) {
    case 0:
    text = "You've reached the end of all of the recent posts from your local area.  To add to this collection, <b>create a post</b> of your own!  To see posts from a larger area around you, go to your <b>regional feed</b>.";
    break;
    case 1:
    text = "You've reached the end of all of the recent posts from your region.  To add to this collection, <b>create a post</b> of your own!  To see posts from around the world, go to your <b>global feed</b>.";
    break;
    case 2:
    text = "You've reached the end of all of the recent posts from around the world.  Impressive!  To add to this collection, <b>create a post</b> of your own.  Or maybe it's time to <b>take a break</b> and go outside for a bit?";
    break;
    case 3:
    text = "You've reached the end of the Users Hall of Fame.  Now that you're inspired, <b>create a post</b> to accumulate more uplifts for yourself!";
    break;
    case 4:
    text = "You've reached the end of the Posts Hall of Fame.  Now that you're inspired, <b>create a post</b> of your own!  Maybe it'll end up here!";
    break;
    case 5:
    text = "You've reached the end of your notifications.  If you want more, <b>create a new post</b>.  Keep on Uplifting!";
    break;
    case 6:
    text = "You've reached the end of your activity.  To add to your activity, <b>create a new post</b>.  Keep on Uplifting!";
    break;
        default: break;
    }
    }else if(context.lastRefresh[layoutNum] != 0){
    title = "Nothing to Show";
    switch (layoutNum) {
    case 0:
    text = "Looks like nobody has posted anything from your local area in a while.  To fix that, <b>create a post</b> of your own!  To see posts from a larger area around you, go to your <b>regional feed</b>.";
    break;
    case 1:
    text = "Looks like nobody has posted anything from your region in a while.  To fix that, <b>create a post</b> of your own!  To see posts from around the world, go to your <b>global feed</b>.";
    break;
    case 2, 3, 4:
    text = "Uplift may be experiencing technical difficulties at the moment.  You can <b>create a post</b> or <b>take a break</b> and come back later.";
    button2 = "Close Uplift for Now";
    break;
    case 5:
    text = "Looks like you haven't received any notifications yet.  To fix that, <b>create a new post</b>.  Uplift the World!";
    break;
    case 6:
    text = "Looks like you haven't posted or uplifted yet.  To fix that, <b>create a new post</b>.  Uplift the World!";
    break;
        default: break;
    }
    }
    break;
    case 7:
    title = "Questions or Comments?";
    text = "Feel free to <b>send us an email</b> by clicking the button below.";
    button1 = "Contact Uplift by Email";
    break;
        default: break;
    }
    
    populate(layoutNum: layoutNum, title: title, text: text ,button1: button1, button2: button2, scroll: context.view_scrolls[layoutNum]);
    }
    
    convenience init(windowWithUser:WindowWithUser){
        self.init(coder:nil)
        
        self.tag = Tag.getTag("bottom")
        LayoutParams.alignParentLeftRight(subview: self)
        //self.backgroundColor = Color.theme
    
    populate(layoutNum: -2, title: "", text: "", button1: "", button2: "", scroll: windowWithUser.scroll);
    }
    
    func populate(layoutNum:Int, title:String, text:String, button1:String, button2:String, scroll:UIScrollView){
    
    self.addSubview(ContentCreator.divider());
    
    let sunset = UIImageView()
        LayoutParams.alignParentLeftRight(subview: sunset)
        LayoutParams.setHeight(view: sunset, height: context.screenWidth / 4)
    sunset.backgroundColor = Color.main_background
    sunset.image = #imageLiteral(resourceName: "sunset")
    self.addSubview(sunset);
    
    if(title != ""){
    
    let messageLayout = VerticalLinearLayout()
        LayoutParams.centerParentHorizontal(subview: messageLayout)
        LayoutParams.setWidth(view: messageLayout, width: 300)
    messageLayout.backgroundColor = .white
        messageLayout.roundCorners(corners: .allCorners, radius: 6)
        self.addSubview(messageLayout, marginTop: 16);
    
    let titleView = UILabelX()
        LayoutParams.alignParentLeftRight(subview: titleView)
        titleView.setInsets(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        titleView.textAlignment = .center
        titleView.text = title
        titleView.textColor = Color.BLACK
        titleView.font = ViewController.typefaceM(20)
    messageLayout.addSubview(titleView);
    
    let textView = UILabelX()
        LayoutParams.alignParentLeftRight(subview: textView)
        textView.setInsets(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
    textView.textAlignment = .center
        textView.textColor = Color.BLACK
        textView.font = ViewController.typefaceR(14)
        textView.setTextFromHtml(text)
    messageLayout.addSubview(textView);
    
    let button1View = UILabelX()
        LayoutParams.alignParentLeftRight(subview: button1View)
        button1View.setInsets(UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8))
        button1View.textAlignment = .center
        button1View.text = button1
    ContentCreator.setUpBoldThemeStyle(button1View, size: 17, italics: true);
        messageLayout.addSubview(button1View, marginTop: -20);
        
        if button2 == ""{
            button1View.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 6)
        }
        
        TouchController.setUniversalOnTouchListener(button1View, allowSpreadMovement: true, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
        if (layoutNum == 7) {
            let address = "feedback@uplifteverything.com"
            if MFMailComposeViewController.canSendMail() {
            let email = MFMailComposeViewController()
            email.mailComposeDelegate = self
            email.setSubject("Uplift for iOS Feedback")
            email.setToRecipients([address]) // the recipient email address
                self.context.present(email, animated: true, completion: nil)
            }else{
                let url = URL(string: "mailto:" + address)!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else {
            let _ = WindowWithCompose()
        }
        }))
        
    if button2 != ""{
    let button2View = UILabelX()
        LayoutParams.alignParentLeftRight(subview: button2View)
    button2View.setInsets(UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8))
        button2View.textAlignment = .center
        button2View.text = button2
    ContentCreator.setUpBoldThemeStyle(button2View, size: 17, italics: true);
    messageLayout.addSubview(button2View);
        
        button2View.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 6)
        
        TouchController.setUniversalOnTouchListener(button2View, allowSpreadMovement: true, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
            switch (layoutNum) {
            case 0, 1:
                self.context.currentSubmode[0] += 1;
                self.context.animate_all();
                break;
            case 2:
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                break;
            default:
                break;
            }
        }))
    }
    }
        
        self.setInsets(UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0)) //special for iOS
    
    let logo = UIImageView()
        LayoutParams.setWidth(view: logo, width: 80)
        LayoutParams.setHeight(view: logo, height: 40)
        LayoutParams.centerParentHorizontal(subview: logo)
    logo.image = #imageLiteral(resourceName: "logo_full")
        self.addSubview(logo, marginTop: 12);
        
        TouchController.setUniversalOnTouchListener(logo, allowSpreadMovement: true, onOffCallback: OnOffCallback(on: {
            let _ = logo.animate().scaleX(0.8).scaleY(0.8).setDuration(100).setInterpolator(.overshoot);
        }, off: {
            let _ = logo.animate().scaleX(1).scaleY(1).setDuration(300).setInterpolator( .overshoot);
        }), clickCallback: ClickCallback(execute: {
            scroll.setContentOffset(.zero, animated: true)
            self.context.animate_all();
        }))
}
}
