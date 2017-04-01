//
//  Login.swift
//  Uplift
//
//  Created by Adam Cobb on 10/12/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit
import Parse
import CoreLocation
import Photos

public class LogIn {
    static weak var context:ViewController!
    
    static var newUser = false;
    
    static func isLoggedIn()->Bool{
    return Files.readBoolean("login_loggedIn", false) && PFUser.current() != nil && PFUser.current()!.isAuthenticated
    }
    
    static var viewToMakeInvisible:UIView?
    static var login_view:UIScrollViewX!
    
    static func update(){
    
    if(!Files.readBoolean("login_loggedIn", false) && PFUser.current() != nil){ //just in case
        loading();
        PFUser.logOutInBackground(block: { e in
            self.update()
        })
    }
        
        CurrentUser.userData = nil
    
    context.layout_login.removeAllViews();
    
    context.layout_splash.animate().cancel();
    context.layout_splash.isHiddenX = false
    context.layout_splash.alpha = 1
    context.layout_login.isHiddenX = false
    
    context.layout_login.touchListener = TouchListener(return: true)
    
    viewToMakeInvisible = nil
        
        if PHPhotoLibrary.authorizationStatus() != .authorized || CLLocationManager.authorizationStatus() != .authorizedWhenInUse{
            init_permission()
    }else if(PFUser.current() == nil) {
    Files.writeBoolean("login_loggedIn", false);
        let installation = PFInstallation.current()!
        installation.fetchIfNeededInBackground(block: { object, e in
            if (e == nil) {
                object!["userId"] = ""
                object!.saveInBackground()
            }
        })
        
    init_login();
    }else if(!PFUser.current()!.isAuthenticated){
    login_view = nil;
    Files.writeString("current_email", CurrentUser.email());
    init_auth();
    }else{
    login_view = nil;
    Files.writeString("current_email", CurrentUser.email());
    init_done();
    }
    }
    
    static func loading(){
    
    context.clearAllFocus()
    
    context.layout_login.removeAllViews();
    
    let layout = VerticalLinearLayout()
    LayoutParams.centerParentVertical(subview: layout)
        LayoutParams.centerParentHorizontal(subview: layout)
    context.layout_login.addSubview(layout);
    
    let logo = UIImageView()
        LayoutParams.setWidthHeight(view: logo, width: 160, height: 80)
        LayoutParams.alignParentLeftRight(subview: logo)
    logo.image = #imageLiteral(resourceName: "logo_full")
    layout.addSubview(logo);
        
        let loading = ProgressBar()
        LayoutParams.setWidthHeight(view: loading, width: 50, height: 50)
        LayoutParams.centerParentHorizontal(subview: loading)
        loading.color = .white
        layout.addSubview(loading, marginTop: 24)
    }
    
    static func init_permission() {
    
        let scroll = UIScrollViewX()
        LayoutParams.alignParentLeftRight(subview: scroll)
        LayoutParams.centerParentVertical(subview: scroll)
        scroll.showsVerticalScrollIndicator = false
        context.layout_login.addSubview(scroll)
        
        NSLayoutConstraint(item: scroll, attribute: .height, relatedBy: .lessThanOrEqual, toItem: context.layout_login, attribute: .height, multiplier: 1, constant: 0).isActive = true
        
        let layout = VerticalLinearLayout()
        LayoutParams.alignParentScrollVertical(subview: layout)
        layout.setInsets(UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0))
        scroll.addSubview(layout);
        
        let c = NSLayoutConstraint(item: scroll, attribute: .height, relatedBy: .equal, toItem: layout, attribute: .height, multiplier: 1, constant: 0)
        c.priority = 1
            c.isActive = true
        
        let logo = UIImageView()
        LayoutParams.setWidthHeight(view: logo, width: 160, height: 80)
        LayoutParams.centerParentHorizontal(subview: logo)
        logo.image = #imageLiteral(resourceName: "logo_full")
        layout.addSubview(logo);
        
        let explanation = UILabelX()
        LayoutParams.setWidth(view: explanation, width: 300)
        LayoutParams.centerParentHorizontal(subview: explanation)
        explanation.setInsets(UIEdgeInsets(top: 12, left: 12, bottom: 8, right: 12))
        explanation.text = "Thanks for downloading Uplift!  We're glad you're here to join us at the Social Network Built on Positivity.  Before we get started, we need to ask your phone for two additional permissions." +
            "\n\n" +
            "First, we need to have access to your photo library to enable you to upload and save images." +
            "\n\n" +
            "Second, we need permission to request your location in order for you to be able to see posts from people around you." +
            "\n\n" +
        "Click on the button below to let us do so."
        explanation.textAlignment = .center
        explanation.textColor = Color.BLACK
        explanation.font = ViewController.typefaceM(14)
        explanation.backgroundColor = Color.WHITE
        layout.addSubview(explanation, marginTop: 24);
    
    let button = UILabelX()
        LayoutParams.setWidth(view: button, width: 300)
        LayoutParams.centerParentHorizontal(subview: button)
    button.textAlignment = .center
        button.setInsets(UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0))
    button.text = "Let Us Request These Permissions"
    button.backgroundColor = Color.WHITE
    ContentCreator.setUpBoldThemeStyle(button, size: 20, italics: true);
    layout.addSubview(button);
        
        context.layout_login.touchListener = TouchListener(touchDown: { _ in
        print("layout login: " + scroll.frame.debugDescription + " " + layout.frame.debugDescription)
            return false
        }, touchMove: {_ in return false}, touchUp: {_ in return false}, touchCancel: {_ in return false})
        
        TouchController.setUniversalOnTouchListener(button, allowSpreadMovement: true, whiteWhenOff: true, clickCallback: ClickCallback(execute: {
            self.loading();
            if PHPhotoLibrary.authorizationStatus() != .authorized{
                PHPhotoLibrary.requestAuthorization({status in
                    
                    if CLLocationManager.authorizationStatus() != .authorizedWhenInUse{
                        self.context.locationManager.requestWhenInUseAuthorization()
                    }else{
                        Async.run(SyncInterface(runTask: {
                            if status == .denied{
                                Toast.makeText(self.context, "Looks like you have denied Uplift access to your photo library.  To use Uplift please grant us this permission in your phone's settings.", Toast.LENGTH_LONG)
                            }
                            self.update()
                        }))
                    }
                })
            }else{
                self.context.locationManager.requestWhenInUseAuthorization()
            }
        }))
    }
    
    static func init_login(){
    context.currentMode = 0;
    context.currentSubmode[0] = 0;
    context.animate_all();
    for i in 0 ..< 8{
        context.lastRefresh[i] = 0;
    }
        
        if let login_view = login_view{
            login_view.removeFromSuperview()
            LayoutParams.alignParentLeftRight(subview: login_view)
            LayoutParams.centerParentVertical(subview: login_view)
            context.layout_login.addSubview(login_view)
            
            NSLayoutConstraint(item: login_view, attribute: .height, relatedBy: .lessThanOrEqual, toItem: context.layout_login, attribute: .height, multiplier: 1, constant: 0).isActive = true
            
            return
        }
    
    login_view = UIScrollViewX()
        LayoutParams.alignParentLeftRight(subview: login_view)
        LayoutParams.centerParentVertical(subview: login_view)
        login_view!.showsVerticalScrollIndicator = false
        context.layout_login.addSubview(login_view)
        
        NSLayoutConstraint(item: login_view, attribute: .height, relatedBy: .lessThanOrEqual, toItem: context.layout_login, attribute: .height, multiplier: 1, constant: 0).isActive = true
    
    let layout = VerticalLinearLayout()
        LayoutParams.alignParentScrollVertical(subview: layout)
        layout.setInsets(UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0))
    login_view.addSubview(layout);
        
        let c = NSLayoutConstraint(item: login_view, attribute: .height, relatedBy: .equal, toItem: layout, attribute: .height, multiplier: 1, constant: 0)
        c.priority = 1
        c.isActive = true
    
    let logo = UIImageView()
        LayoutParams.setWidthHeight(view: logo, width: 160, height: 80)
        LayoutParams.centerParentHorizontal(subview: logo)
    logo.image = #imageLiteral(resourceName: "logo_full")
    layout.addSubview(logo);
    
    let chooseLogin = UILabelX()
        LayoutParams.setWidth(view: chooseLogin, width: 300)
        LayoutParams.centerParentHorizontal(subview: chooseLogin)
    chooseLogin.textAlignment = .center
    chooseLogin.setInsets(UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0))
    chooseLogin.text = "Log In with Existing Account"
    chooseLogin.backgroundColor = Color.WHITE
    ContentCreator.setUpBoldThemeStyle(chooseLogin, size: 20, italics: true);
        layout.addSubview(chooseLogin, marginTop: 24);
    
    let login_layout = VerticalLinearLayout()
        login_layout.isHiddenX = true
    LayoutParams.setWidth(view: login_layout, width: 300)
        LayoutParams.centerParentHorizontal(subview: login_layout)
    login_layout.backgroundColor = Color.WHITE
    login_layout.setInsets(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
    layout.addSubview(login_layout)
    
    let login_email = LabeledEditField(label: "Email Address", fadingLabel: false, textSize: 17, labelSize: 14, errorSize: 11);
        LayoutParams.alignParentLeftRight(subview: login_email)
    login_email.editText.keyboardType = .emailAddress
    login_layout.addSubview(login_email);
    
    login_email.setText(Files.readString("current_email", ""));
    
    let login_password = LabeledEditField(label: "Password", fadingLabel: false, textSize: 17, labelSize: 14, errorSize: 11);
        LayoutParams.alignParentLeftRight(subview: login_password)
        login_password.editText.isSecureTextEntry = true
    login_layout.addSubview(login_password);
    
    let logIn = UILabelX()
        LayoutParams.alignParentLeftRight(subview: logIn)
        logIn.setInsets(UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0))
    logIn.textAlignment = .center
    logIn.text = "Log In"
    ContentCreator.setUpBoldThemeStyle(logIn, size: 20, italics: true);
    login_layout.addSubview(logIn);
    
    let chooseCreate = UILabelX()
        LayoutParams.setWidth(view: chooseCreate, width: 300)
        LayoutParams.centerParentHorizontal(subview: chooseCreate)
        chooseCreate.textAlignment = .center
        chooseCreate.setInsets(UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0))
        chooseCreate.text = "Create a New Uplift Account"
        chooseCreate.backgroundColor = Color.WHITE
        ContentCreator.setUpBoldThemeStyle(chooseCreate, size: 20, italics: true);
        layout.addSubview(chooseCreate, marginTop: 12);
        
        let create_layout = VerticalLinearLayout()
        create_layout.isHiddenX = true
        LayoutParams.setWidth(view: create_layout, width: 300)
        LayoutParams.centerParentHorizontal(subview: create_layout)
        create_layout.backgroundColor = Color.WHITE
        create_layout.setInsets(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        layout.addSubview(create_layout)
    
    let t = UILabelX()
        LayoutParams.alignParentLeftRight(subview: t)
    t.text = "Welcome to Uplift!\n\nPlease upload a profile photo and fill out the following fields to create your new account.\n\nNote: your profile photo and name will be shared publicly when you post something, and we will permanently remove users with misleading or inappropriate profiles.  Appropriate nicknames are acceptable."
        t.setInsets(UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0))
    t.textAlignment = .center
    t.textColor = Color.BLACK
        t.font = ViewController.typefaceM(14)
    create_layout.addSubview(t);
    
    let create_profileLabel = UILabelX()
        LayoutParams.alignParentLeftRight(subview: create_profileLabel)
        create_profileLabel.setInsets(UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0))
    create_profileLabel.text = "Profile Photo"
        create_profileLabel.font = ViewController.typefaceM(14)
    create_profileLabel.textColor = Color.halfBlack
    create_layout.addSubview(create_profileLabel);
    
    let create_profileLayout = UIView()
        LayoutParams.alignParentLeftRight(subview: create_profileLayout)
        create_profileLayout.setInsets(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
    create_layout.addSubview(create_profileLayout);
    
    let create_profile = UIImageView()
        LayoutParams.setWidthHeight(view: create_profile, width: 100, height: 100)
        LayoutParams.alignParentLeft(subview: create_profile)
        LayoutParams.alignParentTopBottom(subview: create_profile)
    create_profile.backgroundColor = Color.view_touchOpaque
    create_profileLayout.addSubview(create_profile);
    
    let create_profileNew = UILabelX()
        LayoutParams.setHeight(view: create_profileNew, height: 60)
        LayoutParams.stackHorizontal(leftView: create_profile, rightView: create_profileNew, margin: 8)
        LayoutParams.alignParentTop(subview: create_profileNew, margin: 20)
        LayoutParams.alignParentRight(subview: create_profileNew)
    create_profileNew.textAlignment = .center
    create_profileNew.text = "Choose and Crop\nNew Photo"
    ContentCreator.setUpBoldThemeStyle(create_profileNew, size: 17, italics: true);
    create_profileLayout.addSubview(create_profileNew);
    
    let create_profileError = UILabelX()
        LayoutParams.alignParentLeftRight(subview: create_profileError)
    create_profileError.setInsets(UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4))
    create_profileError.textColor = Color.flaggedColor
        create_profileError.font = ViewController.typefaceB(11)
    create_layout.addSubview(create_profileError);
    
    let create_name = LabeledEditField(label: "Full Name", fadingLabel: false, textSize: 17, labelSize: 14, errorSize: 11);
        LayoutParams.alignParentLeftRight(subview: create_name)
    create_layout.addSubview(create_name);
    
    let create_email = LabeledEditField(label: "Email Address", fadingLabel: false, textSize: 17, labelSize: 14, errorSize: 11);
        LayoutParams.alignParentLeftRight(subview: create_email)
    create_email.editText.keyboardType = .emailAddress
    create_layout.addSubview(create_email);
    
    let create_password = LabeledEditField(label: "Password", fadingLabel: false, textSize: 17, labelSize: 14, errorSize: 11);
    LayoutParams.alignParentLeftRight(subview: create_password)
    create_password.editText.isSecureTextEntry = true
    create_layout.addSubview(create_password);
    
    let create_confirm = LabeledEditField(label: "Retype Password", fadingLabel: false, textSize: 17, labelSize: 14, errorSize: 11);
    LayoutParams.alignParentLeftRight(subview: create_confirm)
    create_confirm.editText.isSecureTextEntry = true
    create_layout.addSubview(create_confirm);
    
    let create = UILabelX()
        LayoutParams.alignParentLeftRight(subview: create)
    create.setInsets(UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0))
    create.textAlignment = .center
    create.text = "Create Account"
    ContentCreator.setUpBoldThemeStyle(create, size: 20, italics: true);
    create_layout.addSubview(create);
        
        TouchController.setUniversalOnTouchListener(chooseCreate, allowSpreadMovement: true, whiteWhenOff: true, clickCallback: ClickCallback(execute: {
            self.newUser = true;
            create_layout.isHiddenX = false
            login_layout.isHiddenX = true
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                context.layout_login.layoutIfNeeded()
            }, completion: nil)
            
            chooseCreate.font = ViewController.typefaceM(20)
            chooseLogin.font = ViewController.typefaceMI(20)
            self.viewToMakeInvisible = create_layout;
        }))
        
        TouchController.setUniversalOnTouchListener(chooseLogin, allowSpreadMovement: true, whiteWhenOff: true, clickCallback: ClickCallback(execute: {
            self.newUser = false;
            create_layout.isHiddenX = true
            login_layout.isHiddenX = false
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                context.layout_login.layoutIfNeeded()
            }, completion: nil)
            
            chooseCreate.font = ViewController.typefaceMI(20)
            chooseLogin.font = ViewController.typefaceM(20)
            self.viewToMakeInvisible = login_layout;
        }))
        
        TouchController.setUniversalOnTouchListener(create_profileNew, allowSpreadMovement: true, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
            self.context.pictureCallback = PictureIntentCallback(success: { image in
                create_profile.image = image
                ContentCreator.setUpBoldThemeStyle(create_profileLabel, size: 14, italics: false);
            })
            
            self.context.pictureIntent(requestCode: self.context.PROFILE_PICTURE);
        }))
        
        TouchController.setUniversalOnTouchListener(logIn, allowSpreadMovement: true, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
            login_email.setError("");
            login_password.setError("");
            var error = false;
            
            if(login_email.getText() == ""){
                login_email.setError("Please enter your email.");
                error = true;
            }
            
            if(login_password.getText() == ""){
                login_password.setError("Please enter your password.");
                error = true;
            }
            
            if(error){
                Toast.makeText(self.context, "Please review the errors shown in orange above.", Toast.LENGTH_LONG)
            }else{
                loading();
                
                PFUser.logInWithUsername(inBackground: login_email.getText().lowercased(), password: login_password.getText(), block: { user, e in
                    if let e = e{
                        Toast.makeText(self.context, e.localizedDescription, Toast.LENGTH_LONG)
                    }else {
                        Files.writeBoolean("login_loggedIn", true);
                    }
                    update();
                })
                
                login_password.setText("");
            }
        }))
        
        TouchController.setUniversalOnTouchListener(create, allowSpreadMovement: true, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
            create_profileError.text = ""
            create_name.setError("");
            create_email.setError("");
            create_password.setError("");
            create_confirm.setError("");
            
            var error = false;
            
            if (create_profile.image == nil) {
                create_profileError.text = "Please choose a profile photo."
                error = true;
            }
            
            if (create_name.getText() == "") {
                create_name.setError("Please enter your name.");
                error = true;
            }
            
            if (create_email.getText() == "") {
                create_email.setError("Please enter your email address.");
                error = true;
            }
            
            if (create_password.getText().length() < 8) {
                create_password.setError("Please enter a password of at least 8 characters.");
                error = true;
            } else if (create_confirm.getText() != create_password.getText()) {
                create_confirm.setError("Your passwords do not match.");
                error = true;
            }
            
            if(error){
                Toast.makeText(self.context, "Please review the errors shown in orange above.", Toast.LENGTH_LONG)
            }else{
                loading();
                
                Async.run(Async.PRIORITY_INTERNETSMALL, AsyncSyncSuccessInterface(runTask: {
                    let user = PFUser()
                    user.username = create_email.getText().lowercased()
                    user.password = create_password.getText()
                    user.email = create_email.getText().lowercased()
                    user["name"] = create_name.getText()
                    user["uplifts"] = 0
                    user["amountAvailable"] = 0
                    user["amountDonated"] = 0
                    user["rank"] = 123456789
                    
                    let profile = create_profile.image!
                    let profileDimens = [Int(profile.size.width), Int(profile.size.height)]
                    
                    let profileFile = PFFile(name: "profile.png", data: Misc.encodeImage(profile)!)!
                    try profileFile.save();
                    
                    let thumb = profile.scaleImage(toSize: CGSize(width: 288, height: 288))
                    
                    let thumbDimens = [Int(thumb.size.width), Int(thumb.size.height)]
                    
                    let thumbFile = PFFile(name: "thumb", data: Misc.encodeImage(thumb)!)!
                    try thumbFile.save();
                    
                    user["profile"] = profileFile
                    user["profileDimens"] = profileDimens
                    user["thumb"] = thumbFile
                    user["thumbDimens"] = thumbDimens
                    
                    try DataStore.refreshSync();
                    user["currentCharity"] = DataStore.defaultCharity()
                    
                    try user.signUp();
                    
                    return true;
                }, afterTask: { success, message in
                    
                    create_password.setText("");
                    create_confirm.setText("");
                    
                    if (success) {
                        Files.writeBoolean("login_loggedIn", true);
                    } else {
                        Toast.makeText(self.context, "Account creation failed, please try again.", Toast.LENGTH_LONG)
                    }
                    self.update();
                }))
            }
        }))
        
        TouchController.setUniversalOnTouchListener(login_view, allowSpreadMovement: true, clickCallback: ClickCallback(execute: context.clearAllFocus))
    }
    
    static func init_auth(){
    
    let scroll = UIScrollViewX()
        LayoutParams.alignParentLeftRight(subview: scroll)
    LayoutParams.centerParentVertical(subview: scroll)
    scroll.showsVerticalScrollIndicator = false
        context.layout_login.addSubview(scroll)
        
        NSLayoutConstraint(item: scroll, attribute: .height, relatedBy: .lessThanOrEqual, toItem: context.layout_login, attribute: .height, multiplier: 1, constant: 0).isActive = true
        
        let layout = VerticalLinearLayout()
        LayoutParams.alignParentScrollVertical(subview: layout)
        layout.setInsets(UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0))
        scroll.addSubview(layout);
        
        let c = NSLayoutConstraint(item: scroll, attribute: .height, relatedBy: .equal, toItem: layout, attribute: .height, multiplier: 1, constant: 0)
        c.priority = 1
        c.isActive = true
    
        let logo = UIImageView()
        LayoutParams.setWidthHeight(view: logo, width: 160, height: 80)
        LayoutParams.centerParentHorizontal(subview: logo)
        logo.image = #imageLiteral(resourceName: "logo_full")
        layout.addSubview(logo);
    
    let explanation = UILabelX()
        LayoutParams.setWidth(view: explanation, width: 300)
        LayoutParams.centerParentHorizontal(subview: explanation)
        explanation.setInsets(UIEdgeInsets(top: 12, left: 12, bottom: 8, right: 12))
    explanation.text = "Thanks for signing up for Uplift!\n\nWe've sent an email to\n" + PFUser.current()!.email! + "\nto verify that it is your email address.  Please click on the link in the email to complete the verification.\n\nIf you've already completed email verification, click \"Refresh\" below."
        explanation.textAlignment = .center
    explanation.textColor = Color.BLACK
        explanation.font = ViewController.typefaceM(14)
    explanation.backgroundColor = Color.WHITE
        layout.addSubview(explanation, marginTop: 24);
    
    let refresh = UILabelX()
        LayoutParams.setWidth(view: refresh, width: 300)
        LayoutParams.centerParentHorizontal(subview: refresh)
    refresh.textAlignment = .center
        refresh.setInsets(UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0))
    refresh.text = "Refresh"
    refresh.backgroundColor = Color.WHITE
    ContentCreator.setUpBoldThemeStyle(refresh, size: 20, italics: true);
    layout.addSubview(refresh);
    
    context.layout_login.addSubview(scroll);
        
        NSLayoutConstraint(item: scroll, attribute: .height, relatedBy: .lessThanOrEqual, toItem: context.layout_login, attribute: .height, multiplier: 1, constant: 0).isActive = true
    
    let back = UIImageView()
        LayoutParams.setWidthHeight(view: back, width: 56, height: 56)
        back.setInsets(UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))
        back.image = #imageLiteral(resourceName: "back")
    context.layout_login.addSubview(back);
        
        TouchController.setUniversalOnTouchListener(refresh, allowSpreadMovement: true, whiteWhenOff: true, clickCallback: ClickCallback(execute: {
            loading()
            PFUser.current()!.fetchInBackground(block: { object, e in
                update()
            })
        }))
    
        TouchController.setUniversalOnTouchListener(back, allowSpreadMovement: false, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
            loading()
            PFUser.logOutInBackground(block: { e in
                update()
            })
        }))
    }
    
    static func init_done(){
        let installation = PFInstallation.current()!
        installation.fetchIfNeededInBackground(block: { object, e in
            if let object = object as? PFInstallation{
                object["userId"] = CurrentUser.userId()
                object.saveInBackground()
            }
        })
    
    context.layout_login.isHiddenX = true
        
            for i in 0 ..< context.modeNames.count{
                for j in 0 ..< context.submodeNames[i].count{
                    Update.updateLayout(i, j, true, nil)
                }
            }
            
            Async.run(SyncInterface(runTask: {
                Refresh.refreshPage(0, 0);
            }))
            
            Async.run(3000, SyncInterface(runTask: {
                let _ = self.context.layout_splash.animate().alpha(0).setDuration(400).setInterpolator(.linear).setListener(AnimatorListener(onAnimationEnd: {
                    self.context.layout_splash.isHiddenX = true
                }))
            }))
    
    context.notifications_refreshAsync();
    
    if (newUser) {
        Dialog.showTextDialog(title: "You're in!", text: "Welcome, new Uplifter!  We're glad you've now officially joined us." +
            "\n\n" +
            "We're finishing up preparing your personal localized feeds right now but we'll be done in a moment!" +
            "\n\n" +
            "Since you're new here, would you like to view a tutorial of the app?", negativeText: "No Thanks", positiveText: "Yes Please", positiveCallback: DialogCallback(execute: {
            TutorialController.startTutorial();
            return true
        })
        )
    
    newUser = false;
    }
}
}
