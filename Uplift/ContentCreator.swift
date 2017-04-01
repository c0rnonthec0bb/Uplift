//
//  ContentCreator.swift
//  Uplift
//
//  Created by Adam Cobb on 11/4/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit
import Parse
import GoogleMobileAds

class ContentCreator {
    static weak var context:ViewController!
    
    static func setUpBoldThemeStyle(_ textView:UILabelX, size:CGFloat, italics:Bool){
        textView.textColor = Color.theme_bold
        if italics{
        textView.font = ViewController.typefaceMI(size)
        }else{
            textView.font = ViewController.typefaceM(size)
        }
        textView.layer.shadowRadius = size / 32
        textView.layer.shadowOffset = CGSize(width: size / 32, height: size / 32)
        textView.layer.shadowColor = Color.theme_bold.cgColor
        textView.layer.shadowOpacity = 1
    }
    
    static func composeButton() ->UIView {
        let layout = UIView()
        LayoutParams.alignParentLeftRight(subview: layout)
        
        let header = HeaderView()
        header.populate(CurrentUser.user(), nil, nil)
        header.backgroundColor = Color.WHITE
        layout.addSubview(header)
        
        LayoutParams.alignParentTopBottom(subview: header)
        
        let composeButton = UILabelX()
        composeButton.setInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12))
        composeButton.text = "Share Something"
        setUpBoldThemeStyle(composeButton, size: 17, italics: true)
        layout.addSubview(composeButton)
        LayoutParams.centerParentVertical(subview: composeButton)
        LayoutParams.alignParentRight(subview: composeButton)
        
        let cover = UILabelX()
        layout.addSubview(cover)
        LayoutParams.alignParentLeftRight(subview: cover)
        LayoutParams.alignParentTopBottom(subview: cover)
        
        TouchController.setUniversalOnTouchListener(layout, allowSpreadMovement: true, visibleView: cover, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
            let _ = WindowWithCompose()
        }))
        
        ContentCreator2.setUpSides(inView: layout)
        
        return layout;
    }
    
    static func myCharityLayout()->UIView{
        
        let layout = UIView()
        LayoutParams.alignParentLeftRight(subview: layout)
        layout.backgroundColor = Color.WHITE
        
        let title = UILabelX()
        title.textAlignment = .center
        title.setInsets(UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
        title.text = "Your Charity"
        title.textColor = Color.title_textColor
        title.font = ViewController.typefaceM(20)
        layout.addSubview(title)
        LayoutParams.alignParentLeftRight(subview: title)
        LayoutParams.alignParentTop(subview: title)
        
        CharityObject.getCharityObject(CurrentUser.charity(), mustRefresh: false, callback: CharityCallback(success: { charityObject in
            
            let donatedFloor = Misc.floorText(DataStore.totalDonations());
            
            let charity = CharityView(charity: charityObject, isFullCard: false);
            layout.addSubview(charity)
            LayoutParams.stackVertical(topView: title, bottomView: charity)
            LayoutParams.centerParentHorizontal(subview: charity)
            
            let text1 = UILabelX()
            text1.setInsets(UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16))
            text1.textColor = Color.BLACK
            text1.font = ViewController.typefaceR(15)
            text1.textAlignment = .center
            var htmlEncoded = "Every time someone uplifts one of your posts, a small amount of money is automatically donated to <b>" + charityObject.getName()! + "</b>."
            htmlEncoded += "Thanks to users like you, Uplift has donated over <b>" + donatedFloor + " dollars</b> to charity.<br>"
            htmlEncoded += "<b>Here's to " + donatedFloor + " more!</b>"
            text1.setTextFromHtml(htmlEncoded)
            layout.addSubview(text1)
            LayoutParams.alignParentLeftRight(subview: text1)
            LayoutParams.stackVertical(topView: charity, bottomView: text1)
            
            let text2 = UILabelX()
            text2.setInsets(UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0))
            text2.text = "Pick a Different Charity"
            text2.textAlignment = .center
            setUpBoldThemeStyle(text2, size: 17, italics: true);
            layout.addSubview(text2)
            LayoutParams.alignParentLeftRight(subview: text2)
            LayoutParams.stackVertical(topView: text1, bottomView: text2)
            
            TouchController.setUniversalOnTouchListener(text2, allowSpreadMovement: true, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
                let _ = WindowWithCharities()
            }))
            
            LayoutParams.alignParentBottom(subview: text2)
            
            ContentCreator2.setUpSides(inView: layout)
            
            }, error: { message in
                Toast.makeText(context, "Failed to show charity information.", Toast.LENGTH_LONG)
        }))
        
        return layout;
    }
    
    static func statsLayout() ->UIView {
        let layout = BasicViewGroup();
        layout.backgroundColor = Color.WHITE
        
        let title = UILabelX()
        title.textAlignment = .center
        title.text = "Stats"
        title.textColor = Color.BLACK
        title.font = ViewController.typefaceM(20)
        layout.addSubview(title)
        Layout.wrapH(title, l: 0, t: 8, width: context.screenWidth);
        
        var top = title.measuredSize.height + 4
        
        for i in 0..<9{
            let label = UILabelX()
            label.textColor = Color.BLACK
            label.font = ViewController.typefaceR(14)
            layout.addSubview(label)
            
            let value = UILabelX()
            ContentCreator.setUpBoldThemeStyle(value, size: 28, italics: false);
            layout.addSubview(value)
            
            switch (i){
            case 0:
                label.text = "Posts and comments on Uplift:"
                value.text = String(DataStore.totalPostsAndComments())
                break;
            case 1:
                label.text = "Posts and comments you've posted:"
                value.text = String(CurrentUser.postsAndComments())
                break;
            case 2:
                top += 16
                label.text = "Uplifts given on Uplift:"
                value.text = String(DataStore.totalUplifts())
                break;
            case 3:
                label.text = "Uplifts you've received:"
                value.text = String(CurrentUser.uplifts())
                break;
            case 4:
                top += 16
                label.text = "Users on Uplift:"
                value.text = String(DataStore.totalUsers())
                break;
            case 5:
                label.text = "Your rank among Uplift users:"
                value.text = String(CurrentUser.rank())
                break;
            case 6:
                top += 16
                label.text = "Days since the release of Uplift:"
                let timeInMillis = Date().timeInMillis - 1483228800000
                value.text = String(timeInMillis / (1000 * 60 * 60 * 24))
                break;
            case 7:
                label.text = "Days since you joined:"
                let timeInMillis = Date().timeInMillis - CurrentUser.user().object.createdAt!.timeInMillis
                value.text = String(Int64(timeInMillis) / (1000 * 60 * 60 * 24))
                break;
            case 8:
                top += 16
                label.text = "Total raised for charity:"
                value.text = Misc.dollars(DataStore.totalDonations())
            default:break;
            }
            
            let valueDimens = Measure.wrap(value);
            let labelDimens = Measure.wrap(label);
            let centerV = top + max(valueDimens.height, labelDimens.height) / 2;
            let left = (context.screenWidth - valueDimens.width - 4 - labelDimens.width) / 2;
            Layout.exact(label, l: left, t: centerV - labelDimens.height / 2, width: labelDimens.width, height: labelDimens.height);
            Layout.exact(value, l: left + labelDimens.width + 4, t: centerV - valueDimens.height / 2, width: valueDimens.width, height: valueDimens.height);
            top = value.top + Measure.h(value)
        }
        
        top += 20;
        
        LayoutParams.alignParentLeftRight(subview: layout)
        LayoutParams.setHeight(view: layout, height: top)
        
        ContentCreator2.setUpSides(inView: layout)
        
        return layout;
    }
    
    static func infoLayout()->UIView{
        let infoLayout = BasicViewGroup()
        LayoutParams.alignParentLeftRight(subview: infoLayout)
        LayoutParams.setHeight(view: infoLayout, height: 8 + 28 + 26 + 144 + 8)
        infoLayout.backgroundColor = Color.WHITE
        
        let title = UILabelX()
        title.textAlignment = .center
        title.text = "Profile"
        title.textColor = Color.BLACK
        title.font = ViewController.typefaceM(20)
        infoLayout.addSubview(title)
        Layout.wrapH(title, l: 0, t: 8, width: context.screenWidth);
        
        let nameLabel = UILabelX()
        nameLabel.textColor = Color.BLACK
        nameLabel.font = ViewController.typefaceR(14)
        nameLabel.text = "Logged in as "
        infoLayout.addSubview(nameLabel);
        
        let nameValue = UILabelX();
        nameValue.textColor = Color.BLACK
        nameValue.font = ViewController.typefaceM(14)
        nameValue.text = CurrentUser.name()
        infoLayout.addSubview(nameValue);
        
        let nameW = Measure.wrap(nameLabel).width + Measure.wrap(nameValue).width
        Layout.wrap(nameLabel, l: (context.screenWidth - nameW) / 2, t: 8 + 28);
        Layout.wrap(nameValue, l: (context.screenWidth - nameW) / 2 + Measure.w(nameLabel), t: 8 + 28)
        
        let profile = RecyclerImageView(CurrentUser.thumb(), CurrentUser.thumbDimens());
        infoLayout.addSubview(profile);
        Layout.exact(profile, l: 8, t: 8 + 28 + 26, width: 144, height: 144);
        
        let profileCover = UIView();
        infoLayout.addSubview(profileCover);
        Layout.exact(profileCover, l: 8, t: 8 + 28 + 26, width: 144, height: 144);
        
        let changeProfile = UILabelX();
        changeProfile.textAlignment = .center
        changeProfile.text = "Choose and Crop\nNew Profile Photo"
        setUpBoldThemeStyle(changeProfile, size: 17, italics: true);
        infoLayout.addSubview(changeProfile);
        Layout.exact(changeProfile, l: 8 + 144 + 8, t: 8 + 28 + 26, width: context.screenWidth - (8 + 144 + 8 + 8), height: 64);
        
        let changeName = UILabelX();
        changeName.textAlignment = .center
        changeName.text = "Change Name"
        setUpBoldThemeStyle(changeName, size: 17, italics: true);
        infoLayout.addSubview(changeName);
        Layout.exact(changeName, l: 8 + 144 + 8, t: 8 + 28 + 26 + 64, width: context.screenWidth - (8 + 144 + 8 + 8), height: 40);
        
        let changePassword = UILabelX();
        changePassword.textAlignment = .center
        changePassword.text = "Reset Password"
        setUpBoldThemeStyle(changePassword, size: 17, italics: true);
        infoLayout.addSubview(changePassword);
        Layout.exact(changePassword, l: 8 + 144 + 8, t: 8 + 28 + 26 + 64 + 40, width: context.screenWidth - (8 + 144 + 8 + 8), height: 40);
        
        TouchController.setUniversalOnTouchListener(nameValue, allowSpreadMovement: true, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
            let _ = WindowWithUser(user: CurrentUser.user())
        }))
        
        TouchController.setUniversalOnTouchListener(profileCover, allowSpreadMovement: true, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
            let image = [CurrentUser.thumb()]
            let dimens = [CurrentUser.profileDimens()]
            let _ = WindowWithImages(name: CurrentUser.name(), images: image, dimens: dimens, startImage: 0, startImageView: profile, highQualityCallback: GetImagesCallback(executeSync: {
                return [CurrentUser.profile()]
            }))
        }))
        
        TouchController.setUniversalOnTouchListener(changeProfile, allowSpreadMovement: true, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
            context.pictureCallback = PictureIntentCallback(success: { image in
             Update.updateLayout(3, 0, true)
             })
             context.pictureIntent(requestCode: context.PROFILE_PICTURE)
        }))
        
        TouchController.setUniversalOnTouchListener(changeName, allowSpreadMovement: true, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
            let layout = UIView()
            layout.setInsets(UIEdgeInsets(top: 12, left: 16, bottom: 4, right: 16))
            
            let textView = UILabelX()
            textView.textAlignment = .center
            textView.text = "For security reasons, all name changes must be reviewed by our team.  Though appropriate nicknames are allowed, names which are incorrect will be rejected (in other words, you can't pose as someone else).  Type your new name below to submit it for review.  Name review should take less than one week, and we'll send you an email when it's done."
            textView.textColor = Color.BLACK
            textView.alpha = 0.5
            textView.font = ViewController.typefaceR(14)
            layout.addSubview(textView);
            LayoutParams.alignParentLeftRight(subview: textView)
            LayoutParams.alignParentTop(subview: textView)
            
            let newName = LabeledEditField(label: "New Name", fadingLabel: false, textSize: 17, labelSize: 14, errorSize: 11);
            layout.addSubview(newName);
            LayoutParams.alignParentLeftRight(subview: newName)
            LayoutParams.stackVertical(topView: textView, bottomView: newName, margin: 8)
            LayoutParams.alignParentBottom(subview: newName)
            
            Dialog.showDialog(title: "Change Name", contentView: layout, negativeText: "Cancel", positiveText: "Submit New Name", positiveCallback: DialogCallback(execute: {
                if(newName.getText() == ""){
                    Toast.makeText(context, "Please enter your desired new name.", Toast.LENGTH_SHORT)
                    newName.setError("Please enter your desired new name.");
                    return false;
                }else {
                    Upload.submitNewName(newName.getText());
                    return true;
                }
            }))
        }))
        
        TouchController.setUniversalOnTouchListener(changePassword, allowSpreadMovement: true, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
            Dialog.showTextDialog(title: "Reset Password", text: "We'll send an email to\n" + CurrentUser.email() + "\nwith a link to create a new password.", negativeText: "Cancel", positiveText: "Reset", positiveCallback: DialogCallback(execute: {
                PFUser.requestPasswordResetForEmail(inBackground: CurrentUser.email())
                return true;
            }))
        }))
        
        ContentCreator2.setUpSides(inView: infoLayout)
        
        return infoLayout;
    }
    
    static func fullWidthButtonView(text:String, callback:ClickCallback)->UIView{
        let layout = UIView()
        LayoutParams.alignParentLeftRight(subview: layout)
        LayoutParams.setHeight(view: layout, height: 48)
        layout.backgroundColor = Color.WHITE
        
        let textView = UILabelX();
        textView.textAlignment = .center
        textView.text = text
        setUpBoldThemeStyle(textView, size: 17, italics: true);
        layout.addSubview(textView);
        LayoutParams.alignParentLeftRight(subview: textView)
        LayoutParams.alignParentTopBottom(subview: textView)
        
        TouchController.setUniversalOnTouchListener(layout, allowSpreadMovement: true, whiteWhenOff: true, clickCallback: callback);
        
        ContentCreator2.setUpSides(inView: layout)
        
        return layout;
    }
    
    static func adView()->UIView{
        let layout = UIView()
        LayoutParams.alignParentLeftRight(subview: layout)
        LayoutParams.setHeight(view: layout, height: 50)
        layout.backgroundColor = Color.WHITE
        
        let loadingAd = UILabelX();
        loadingAd.textAlignment = .center
        loadingAd.text = "Loading sponsored content..."
        setUpBoldThemeStyle(loadingAd, size: 14, italics: false);
        layout.addSubview(loadingAd);
        LayoutParams.alignParentLeftRight(subview: loadingAd)
        LayoutParams.setHeight(view: loadingAd, height: 50)
        LayoutParams.alignParentTop(subview: loadingAd)
        
        Async.run(SyncInterface(runTask: {
            let adView = GADBannerView()
            adView.adUnitID = "ca-app-pub-1109483690972683/2267462852"
            adView.rootViewController = context
            adView.isAutoloadEnabled = false
            
            layout.addSubview(adView);
            
            LayoutParams.setWidth(view: adView, width: 350)
            LayoutParams.setHeight(view: adView, height: 50)
            LayoutParams.alignParentTop(subview: adView)
            LayoutParams.centerParentHorizontal(subview: adView)
            
            Async.run(500, SyncInterface(runTask:{
                let request = GADRequest()
                request.testDevices = [kGADSimulatorID, "6cd811847779840398823cdc1e89920b"]
                adView.load(request)
            }));
        }))
        
        ContentCreator2.setUpSides(inView: layout)
        
        return layout;
    }
    
    static func divider()->UIView{
        let divider = UIView();
        LayoutParams.alignParentLeftRight(subview: divider)
        LayoutParams.setHeight(view: divider, height: 8)
        divider.backgroundColor = Color.main_background
        return divider;
    }
    
    static func shadow(top:Bool, alpha:CGFloat)->UIView{
        
        let view = UIView()
        LayoutParams.setHeight(view: view, height: 1.5)
        LayoutParams.alignParentLeftRight(subview: view)
        view.alpha = alpha
        view.backgroundImage = Drawables.shadow_gradient()
        
        if(top){
            view.rotation = 180
        }
        
        return view;
    }
    
    static func pointWithinRect(x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat)->Bool{
        return x >= 0 && y >= 0 && x <= width && y <= height;
    }
}
