//
//  WindowWithImages.swift
//  Uplift
//
//  Created by Adam Cobb on 12/30/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class WindowWithImages : WindowBase{
    var imageFrame:UIView!
    var imageViews:[UIImageViewX] = []
    var m_images:[Data] = []
    var m_dimens:[[Int]] = []
    var currentImage:Int!
    
    var imageNums:[UILabelX] = []
    var indicator:UIImageViewX!
    
    convenience init(name:String, images:[Data], dimens:[[Int]], startImage:Int, startImageView:UIView, highQualityCallback:GetImagesCallback?){
        self.init(name: name, images: images, dimens: dimens, startImage: startImage, startTranslation: Misc.getLocationInViews(startImageView).y, startCenter: Misc.getLocationInViews(startImageView).x + Measure.w(startImageView) / 2, startHeight: Measure.h(startImageView), highQualityCallback: highQualityCallback);
    }
    
    init(name:String, images:[Data], dimens:[[Int]], startImage:Int, startTranslation:CGFloat, startCenter:CGFloat, startHeight:CGFloat, highQualityCallback:GetImagesCallback?){
    super.init();
    
    if(WindowBase.topShownWindow() != nil && WindowBase.topShownWindow() is  WindowWithImages){
        WindowBase.instances.remove(element: self);
    return;
    }
    
    m_images = images;
    m_dimens = dimens;
    currentImage = startImage;
        
        buildImages()
    
    buildExpand();
    buildTitle("Image" + ((images.count > 1) ? "s" : "") + " by " + name);
    buildFrame();
    moveImages(ratio: CGFloat(startImage));
    
    //instead of showFrame():
    
    shown = true;
    layout_windows.isHiddenX = false
    frame.isHiddenX = false
    frame.alpha = 0
    
    frame.translationY = startTranslation - topH //title height and top margin of image
    
    var topMargin = context.screenHeight - topH //split up for Swift
        topMargin -= context.screenWidth * CGFloat(dimens[startImage][1]) / CGFloat(dimens[startImage][0])
        topMargin /= 2
    if(topMargin < 0){
    topMargin = 0;
    }
    let scale = startHeight / (context.screenHeight - topH - topMargin * 2);
    
    let startImageView = imageViews[startImage];
    startImageView.scaleX = scale
    startImageView.scaleY = scale
    startImageView.translationY = -(context.screenHeight - topH) / 2 * (1 - scale) - topMargin * scale
    startImageView.translationX = startCenter - context.screenWidth / 2
    
        let _ = frame.animate().alpha(1).setStartDelay(0).setDuration(300).setInterpolator(.linear).setListener(AnimatorListener(onAnimationEnd:{
            let _ = startImageView.animate().scaleX(1).scaleY(1).translationX(0).translationY(0).setDuration(300).setInterpolator(.decelerate);
            self.showFrame();
        }))
        
        if let highQualityCallback = highQualityCallback{
            
            let squircle = ProgressBar();
            squircle.setInsets(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
            squircle.backgroundImage = Drawables.circle_white()
            imageFrame.addSubview(squircle)
            LayoutParams.setWidthHeight(view: squircle, width: 50, height: 50)
            LayoutParams.centerParentHorizontal(subview: squircle)
            LayoutParams.centerParentVertical(subview: squircle)
            
            Async.run(Async.PRIORITY_INTERNETBIG, AsyncSyncInterface(runTask: {
                self.m_images = highQualityCallback.executeSync();
            }, afterTask: {
                
                squircle.removeFromSuperview()
                
                for i in 0 ..< self.m_images.count {
                    self.imageViews[i].image = Misc.decodeImage(self.m_images[i])
                }
            }))
        }
}

func buildImages(){
    
    imageFrame = UIView()
    imageFrame.backgroundColor = Color.theme_0_25
    
    imageViews.removeAll()
    
    for image in m_images {
        
        let imageView = UIImageViewX()
        LayoutParams.alignParentLeftRight(subview: imageView)
        LayoutParams.alignParentTopBottom(subview: imageView)
        imageView.image = Misc.decodeImage(image)
        imageFrame.addSubview(imageView);
        imageViews.append(imageView)
    }
    
    setImagePinchTouchListener(primaryImage: currentImage);
    
    content = imageFrame;
}

override func buildExpand(){
    super.buildExpand();
    
    print("expandH: " + expandH.description)
    
    let expandView = self.expandView!
    
    let imagesText = UILabelX()
    imagesText.font = ViewController.typefaceM(17)
    imagesText.textColor = Color.halfBlack
    imagesText.text = (imageViews.count > 1 ? String(imageViews.count) + " Images:" : "1 Image")
    expandView.addSubview(imagesText);
    Layout.wrapW(imagesText, l: 8, t: 0, height: expandH);
    
    if(imageViews.count > 1){
        
        imageNums.removeAll()
        for i in 0 ..< imageViews.count{
            let item = UILabelX()
            item.textAlignment = .center
            item.text = String(i + 1)
            item.textColor = Color.title_textColor
            item.font = ViewController.typefaceM(17)
            expandView.addSubview(item);
            Layout.exact(item, l: Measure.w(imagesText) + 8 + 4 + 32 * CGFloat(i), t: -2, width: 32, height: expandH + 4);
            imageNums.append(item)
            
            TouchController.setUniversalOnTouchListener(item, allowSpreadMovement: false, onOffCallback: OnOffCallback(on:{
                if self.currentImage == i{
                    item.backgroundColor = Color.title_touch
                }else{
                    item.backgroundColor = Color.title_touch_extra
                }
            }, off: {
                item.backgroundColor = .clear
            }), clickCallback: ClickCallback(execute: {
                self.animateImages(ratio: CGFloat(i))
            }))
        }
        indicator = UIImageViewX()
        indicator.image = #imageLiteral(resourceName: "title_indicator")
        expandView.addSubview(indicator);
        Layout.exactUp(indicator, l: Measure.w(imagesText) + 8 + 4, b: expandH, width: 32, height: 8);
    }
    
    let saveIcon = UIImageViewX()
    saveIcon.image = #imageLiteral(resourceName: "save_theme")
    expandView.addSubview(saveIcon);
    
    let saveImage = UILabelX()
    saveImage.textColor = Color.theme
    saveImage.font = ViewController.typefaceMI(17)
    saveImage.text = "Save Image"
    saveImage.setInsets(UIEdgeInsets(top: 0, left: expandH - 4, bottom: 0, right: 12))
    expandView.addSubview(saveImage);
    Layout.wrapWLeft(saveImage, r: context.screenWidth, t: 0, height: expandH);
    
    Layout.exact(saveIcon, l: context.screenWidth - Measure.w(saveImage), t: 0, width: expandH, height: expandH);
    
    TouchController.setUniversalOnTouchListener(saveImage, allowSpreadMovement: false, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
        Toast.makeText(self.context, "Saving image...", Toast.LENGTH_SHORT)
        
        UIImageWriteToSavedPhotosAlbum(self.imageViews[self.currentImage].image!, self, #selector(self.imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
    }))
}
    
    //added as iOS callback func
    func imageSaved(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if error == nil{
            Async.toast("Successfully saved image.", true);
        }else{
            Async.toast("Failed to save image.", true);
        }
    }

    func moveImages(ratio:CGFloat){
    for i in 0 ..< imageViews.count{
        imageViews[i].translationX = (CGFloat(i) - ratio) * context.screenWidth
    }
    
        if(imageViews.count < 2){
            return;
        }
    
    if(round(ratio) != ratio && !expandShown){
        showExpand(permanent: false);
    }
    
    for i in 0 ..< imageViews.count{
        let amountEnhanced = max(0, 1 - abs(CGFloat(i) - ratio));
        imageNums[i].alpha = 0.6 + 0.4 * amountEnhanced
        imageNums[i].translationY = -2 * amountEnhanced
    }
    
    indicator.translationX = 32 * ratio
}

    func animateImages(ratio:CGFloat){
    currentImage = Int(ratio)
    
        let duration:Int64 = 400;
    let currentRatio = -imageViews[0].translationX / context.screenWidth;
    for i in 0 ..< imageViews.count {
        let _ = imageViews[i].animate().translationX((CGFloat(i) - ratio) * context.screenWidth).setDuration(duration).setInterpolator(.decelerate);
    }
    
    setImagePinchTouchListener(primaryImage: Int(ratio));
    
        if(imageViews.count < 2){
            return;
        }
    
        if(expandShownTemp){
            Async.run(800, SyncInterface(runTask: {
                self.hideExpand()
            }))
        }
    
    for i in 0 ..< imageViews.count {
        if(Misc.isBetween(CGFloat(i), num1: currentRatio, num2: ratio, orWithin1: true) && ratio != currentRatio){
            let direction = CGFloat(ratio - currentRatio).sign()
            let distance = abs(ratio - currentRatio);
            let toStartA = max(0, ((CGFloat(i) - direction) - currentRatio) * direction)
            let toStart = Int64(toStartA / distance * CGFloat(duration));
            let toEnhancedA = max(0, (CGFloat(i) - currentRatio) * direction)
            let toEnhanced = Int64(toEnhancedA / distance * CGFloat(duration));
            let toReturnA = max(0, ((CGFloat(i) + direction) - currentRatio) * direction)
            let toReturn = Int64(toReturnA / distance * CGFloat(duration));
            
            if(toEnhanced > 0){
                Async.run(toStart, SyncInterface(runTask:{
                    let _ = self.imageNums[i].animate().alpha(1).translationY(-2).setDuration(toEnhanced - toStart).setInterpolator(.linear);
                }))
            }
    
            if(toReturn > 0 && toReturn <= duration){
                Async.run(toEnhanced, SyncInterface(runTask: {
                    let _ = self.imageNums[i].animate().alpha(0.6).translationY(0).setDuration(toReturn - toEnhanced).setInterpolator(.linear);
                }))
            }
        }
    }
        
let _ = indicator.animate().translationX(32 * ratio).setDuration(duration).setInterpolator(.decelerate);
}

    func setImagePinchTouchListener(primaryImage:Int){
        TouchController.setImagePinchTouchListener(imageFrame: imageFrame, imageView: imageViews[primaryImage], imageWidth: CGFloat(m_dimens[primaryImage][0]), imageHeight: CGFloat(m_dimens[primaryImage][1]), minScale: 1, window: self, callback: ImagePinchCallback(dragX: { transX in
            if(transX - self.context.screenWidth * CGFloat(primaryImage) <= 0 && transX + self.context.screenWidth * CGFloat(self.imageViews.count - 1 - primaryImage) >= 0){
                self.moveImages(ratio: -transX / self.context.screenWidth + CGFloat(primaryImage));
                return true;
            }else if(transX - self.context.screenWidth * CGFloat(primaryImage) > 0){
                self.moveImages(ratio: 0);
            }else{
                self.moveImages(ratio: CGFloat(self.imageViews.count - 1));
            }
            return false;
        }, dragUp: { dx in
            if(self.imageViews[0].translationX.remainder(dividingBy: self.context.screenWidth) != 0 && self.imageViews[0].scaleX == 1){
                var newImage:CGFloat!
                if(abs(dx) < 1){
                    newImage = round(-self.imageViews[0].translationX / self.context.screenWidth);
                }else if(dx < 0){
                    newImage = floor(-self.imageViews[0].translationX / self.context.screenWidth) + 1
                }else{
                    newImage = floor(-self.imageViews[0].translationX / self.context.screenWidth)
                }
                if(newImage < 0){
                    newImage = 0;
                }
                if(newImage > CGFloat(self.imageViews.count - 1)){
                    newImage = CGFloat(self.imageViews.count - 1);
                }
                self.animateImages(ratio: newImage);
                return true;
            }
            return false;
        }))
    }

    override func hideFrame(send:Bool) {
        super.hideFrame(send: send);
        //todo recycle bitmaps, not necessary here?
}
}
