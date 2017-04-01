//
//  WindowWithCrop.swift
//  Uplift
//
//  Created by Adam Cobb on 12/31/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit
import Parse

class WindowWithCrop: WindowBase {
    init(image:UIImage){
    
    super.init();
    
    if(WindowBase.topShownWindow() != nil) {
        WindowBase.instances.remove(element: self);
    return;
    }
    
    buildTitle("Crop Profile Photo");
        buildCrop(image: image);
    buildFrame();
    showFrame();
    }
    
    func buildCrop(image:UIImage){
    
    let imageWidth = image.size.width
    let imageHeight = image.size.height
    
    let layout = VerticalLinearLayout()
    layout.backgroundColor = Color.main_background
    
    let text = UILabelX()
        LayoutParams.alignParentLeftRight(subview: text)
        text.setInsets(UIEdgeInsets(top: 0, left: 12, bottom: 8, right: 12))
    text.textAlignment = .center
    text.text = "Your profile photo will be shown to other users as a square.  Pinch and drag it to crop it as you wish.  Click \"Done\" when you're happy!"
    text.textColor = Color.BLACK
        text.font = ViewController.typefaceM(17)
    layout.addSubview(text);
    
    let v = UIView()
        LayoutParams.alignParentLeftRight(subview: v)
        LayoutParams.setHeight(view: v, height: 4)
    v.backgroundColor = Color.WHITE
    layout.addSubview(v);
    
    let imageFrame = UIView()
        LayoutParams.alignParentLeftRight(subview: imageFrame)
        LayoutParams.setHeight(view: imageFrame, height: context.screenWidth)
    layout.addSubview(imageFrame);
    
    let imageView = UIImageViewX()
        LayoutParams.alignParentLeftRight(subview: imageView)
        LayoutParams.alignParentTopBottom(subview: imageView)
    imageView.image = image
    imageFrame.addSubview(imageView);
    
    let minScale = max(imageHeight / imageWidth, imageWidth / imageHeight);
        imageView.scaleX = minScale
        imageView.scaleY = minScale
    
    let done = UILabelX()
        LayoutParams.alignParentLeftRight(subview: done)
        done.setInsets(UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0))
    done.textAlignment = .center
    done.text = "Done"
    ContentCreator.setUpBoldThemeStyle(done, size: 20, italics: true);
    done.backgroundColor = Color.WHITE
    layout.addSubview(done);
    
        TouchController.setImagePinchTouchListener(imageFrame: imageFrame, imageView: imageView, imageWidth: imageWidth, imageHeight: imageHeight, minScale: minScale, window: self, callback: ImagePinchCallback(dragX: {transX in
            return false
        }, dragUp: { dx in
            return false
        }))
        
        TouchController.setUniversalOnTouchListener(done, allowSpreadMovement: true, whiteWhenOff: true, clickCallback: ClickCallback(execute: {
            done.touchListener = nil
            done.textColor = Color.halfBlack
            
            let user = CurrentUser.user()
            if (user.object != nil) {
                Toast.makeText(self.context, "Uploading new profile photo...", Toast.LENGTH_LONG)
            }
            
            let imageCropped = UIImage(view: imageFrame)
            
            Async.run(Async.PRIORITY_INTERNETSMALL, AsyncSyncSuccessInterface(runTask: {
                if (user.object == nil){
                    return true;
                }
                
                let encoded = Misc.encodeImage(imageCropped)!
                
                Async.run(SyncInterface(runTask: {
                    self.hideFrame(send: true)
                }))
                
                let profileDimens = [imageCropped.size.width, imageCropped.size.height]
                
                let profileFile = PFFile(name: "profile.png", data: encoded)!
                try profileFile.save();
                
                let thumb = imageCropped.scaleImage(toSize: CGSize(width: 288, height: 288))
                
                let thumbDimens = [thumb.size.width, thumb.size.height]
                
                let thumbFile = PFFile(name: "thumb.png", data: Misc.encodeImage(thumb)!)!
                try thumbFile.save();
                
                user.object["profile"] =  profileFile
                user.object["profileDimens"] = profileDimens
                user.object["thumb"] = thumbFile
                user.object["thumbDimens"] = thumbDimens
                try user.object.save();
                return true;
            }, afterTask: { success, message in
                if (success) {
                    if(user.object == nil){
                        self.hideFrame(send: true);
                    }else{
                    Toast.makeText(self.context, "Successfully uploaded new profile photo.", Toast.LENGTH_SHORT)
                    }
                }else{
                    Toast.makeText(self.context, "Failed to upload new profile photo.", Toast.LENGTH_LONG)
                }
                self.context.pictureCallback!.success(imageCropped);
                Update.updateLayout(3, 0, true);
            }))
        }))
    
    content = layout;
    }
}
