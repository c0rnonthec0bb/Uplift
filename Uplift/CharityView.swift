//
//  CharityView.swift
//  Uplift
//
//  Created by Adam Cobb on 11/5/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class CharityView: UIView {
    
    weak var context:ViewController! = ViewController.context
    
    var cover:UIView!
    
    required init(coder:NSCoder?){
        
        if coder == nil{
            super.init(frame: .zero)
        }else{
            super.init(coder: coder!)!
        }
    }
    
    convenience init(charity:CharityObject, isFullCard:Bool){
        self.init(coder: nil)
    
    cover = UIView()
        LayoutParams.alignParentLeftRight(subview: cover) //special in iOS
        LayoutParams.alignParentTopBottom(subview: cover)
    
        var topMarginHeight:CGFloat = 0;
    
    if isFullCard {
    self.backgroundColor = Color.WHITE
    topMarginHeight = 8
    let topMargin = UIView()
        LayoutParams.alignParentLeftRight(subview: topMargin)
        LayoutParams.alignParentTop(subview: topMargin)
        LayoutParams.setHeight(view: topMargin, height: topMarginHeight)
    topMargin.backgroundColor = Color.main_background
    addSubview(topMargin);
    }
    
    let imageView = RecyclerImageView(charity.getPicture(), 240, 240);
    imageView.setViewDimens(width: isFullCard ? 60 : 54, height: isFullCard ? 60 : 54) //sets w and h
        LayoutParams.setEqualConstraint(view1: imageView, attribute1: .left, view2: self, attribute2: .left, margin: 8)
        LayoutParams.setEqualConstraint(view1: imageView, attribute1: .top, view2: self, attribute2: .top, margin: 8 + topMarginHeight)
    if !isFullCard{
    LayoutParams.setEqualConstraint(view1: self, attribute1: .bottom, view2: imageView, attribute2: .bottom, margin: 8)
    }
    self.addSubview(imageView);
    
    let name = UILabelX()
        LayoutParams.stackHorizontal(leftView: imageView, rightView: name, margin: 8)
        LayoutParams.setEqualConstraint(view1: name, attribute1: .top, view2: self, attribute2: .top, margin: 12 + topMarginHeight)
        LayoutParams.setEqualConstraint(view1: self, attribute1: .right, view2: name, attribute2: .right, margin: 8)
    name.text = charity.getName()
    name.textColor = Color.BLACK
        name.font = ViewController.typefaceM(isFullCard ? 20 : 17)
        name.numberOfLines = 1
        name.lineBreakMode = .byTruncatingTail
    self.addSubview(name);
    
    let shortD = UILabelX()
        LayoutParams.stackHorizontal(leftView: imageView, rightView: shortD, margin: 8)
        LayoutParams.stackVertical(topView: name, bottomView: shortD)
        LayoutParams.setEqualConstraint(view1: self, attribute1: .right, view2: shortD, attribute2: .right, margin: 8)
    shortD.text = charity.getShort()
    shortD.textColor = Color.timeColor
        shortD.font = ViewController.typefaceM(isFullCard ? 17 : 14)
        shortD.numberOfLines = 1
        shortD.lineBreakMode = .byTruncatingTail
    self.addSubview(shortD);
    
    if !isFullCard {
    
    self.addSubview(cover);
        
        TouchController.setUniversalOnTouchListener(self, allowSpreadMovement: true, visibleView: cover, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
            let _ = WindowWithCharities(startId: charity.object!.objectId!);
        }))
    return;
    }
    
    let linkView = TitleAndLinkView(colorTheme: TitleAndLinkView.LINK, width: context.screenWidth - 32);
        linkView.populate(title: "Official Charity Website", link: charity.getLink()!, colored: true, callback: ClickCallback(execute: {
            let _ = WindowWithWebView(link: charity.getLink()!, title: charity.getName()!);
        }))
        
        LayoutParams.setEqualConstraint(view1: linkView, attribute1: .left, view2: self, attribute2: .left, margin: 16)
        LayoutParams.setEqualConstraint(view1: self, attribute1: .right, view2: linkView, attribute2: .right, margin: 16)
        LayoutParams.stackVertical(topView: imageView, bottomView: linkView, margin: 8)
        LayoutParams.setHeight(view: linkView, height: TitleAndLinkView.H)
    self.addSubview(linkView);
    
    let longD = UILabelX()
        LayoutParams.setEqualConstraint(view1: longD, attribute1: .left, view2: self, attribute2: .left, margin: 16)
        LayoutParams.setEqualConstraint(view1: self, attribute1: .right, view2: longD, attribute2: .right, margin: 16)
        LayoutParams.stackVertical(topView: linkView, bottomView: longD, margin: 8)
    longD.textAlignment = .left
    longD.text = charity.getLong()
    longD.textColor = Color.BLACK
        longD.font = ViewController.typefaceR(17)
    self.addSubview(longD);
    
    let donated = UILabelX()
        LayoutParams.setEqualConstraint(view1: donated, attribute1: .left, view2: self, attribute2: .left, margin: 8)
        LayoutParams.setEqualConstraint(view1: self, attribute1: .right, view2: donated, attribute2: .right, margin: 8)
        LayoutParams.stackVertical(topView: longD, bottomView: donated, margin: 16)
    donated.textAlignment = .center
        
    donated.text = Misc.dollars(charity.getDonated()) + " has been raised for this charity on Uplift"
        donated.font = ViewController.typefaceM(14)
    self.addSubview(donated);
    
    let button = UILabelX()
        LayoutParams.alignParentLeftRight(subview: button)
        LayoutParams.setHeight(view: button, height: 36)
        LayoutParams.stackVertical(topView: donated, bottomView: button, margin: 2)
        LayoutParams.alignBottom(view1: self, view2: button)
    button.textAlignment = .center
    if CurrentUser.charity() == charity.object!.objectId {
    button.text = "This is Your Chosen Charity"
    }else{
    button.text = "Choose This Charity as Your Charity"
    }
    ContentCreator.setUpBoldThemeStyle(button, size: 17, italics: true);
    self.addSubview(button);
    
    self.addSubview(cover);
    
    if(CurrentUser.charity() != charity.object!.objectId) {
        
        TouchController.setUniversalOnTouchListener(button, allowSpreadMovement: true, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
            Dialog.showTextDialog(title: "Change Your Charity", text: "Would you like to change your charity of choice to " + charity.getName()! + "?  Future uplifts on any of your posts will result in a donation to this charity.", negativeText: "Cancel", positiveText: "Change Charity", positiveCallback: DialogCallback(execute: {
                let currentUser = CurrentUser.user();
                currentUser.object["currentCharity"] = charity.object!.objectId!
                currentUser.object.saveEventually({ (success:Bool, e:Error?) in
                    if success{
                    Toast.makeText(self.context, "Your charity has been changed to " + charity.getName()! + ".", Toast.LENGTH_LONG)
                    Refresh.refreshPage(3, 0);
                    WindowBase.topShownWindow()!.hideFrame(send: false);
                    }else{
                        Toast.makeText(self.context, "Failed to change your charity.", Toast.LENGTH_LONG)
                    }
                })
                return true;
            }))
        }))
    }
    }
    
}
