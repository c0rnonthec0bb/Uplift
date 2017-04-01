//
//  ComposeView.swift
//  Uplift
//
//  Created by Adam Cobb on 12/12/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class ComposeView : VerticalLinearLayout{
    
    weak var context:ViewController! = ViewController.context
    
    static var bottomH:CGFloat!
    let bottomH:CGFloat = ComposeView.bottomH
    
    var postId:String?
    
    var textEdit:LabeledEditText!
    var contentLayout:UIView!
    var contentLayoutInner = UIView() //iOS Specific
    var addAnotherLayout:UIView!
    var addAnotherImage:UIImageViewX!
    var addAnotherText:UILabelX!
    
    var quickView:VerticalLinearLayout!
    var quickMessage:UILabelX!
    var quickEdit:LabeledEditText!
    var quickHeader:HeaderView!
    
    var updateBottomCallback:UpdateCallback?
    var newContentCallback:UpdateCallback?
    
    var bottomView:BasicViewGroup!
    var bottomAttachLayout:BasicViewGroup!
    var bottomRemoveLayout:BasicViewGroup!
    var bottomRemoveText:UILabelX!
    var sendText:UILabelX!
    
    var preSendCallback:[PreSendCallback] = []
    
    var contentType = -1;
    var contentTitle:[String] = []
    var contentText:[String] = []
    var media:[Data] = []
    var mediaDimens:[[Int]] = []
    var thumbs:[Data] = []
    var thumbsDimens:[[Int]] = []
    
    convenience init(id:String?){ //null id => post; else => comment
        
        self.init(coder: nil)
        
        ViewHelper.onDidLayoutSubviews[self] = { //this is the only required execute for iOS
            if let updateBottomCallback = self.updateBottomCallback{
                updateBottomCallback.execute()
            }
        }
        
        self.backgroundColor = Color.WHITE
        
        postId = id;
        
        let space = UIView()
        space.backgroundColor = Color.main_background
        self.addSubview(space);
        LayoutParams.alignParentLeftRight(subview: space)
        LayoutParams.setHeight(view: space, height: 8)
        
        let header = HeaderView();
        header.populate(CurrentUser.user(), nil, nil);
        self.addSubview(header);
        
        textEdit = LabeledEditText(label: postId == nil ? "Write your post here" : "Write your comment here", fadingLabel: true, textSize: 17, labelSize: 14, errorSize: 11);
        self.addSubview(textEdit, marginTop: -6);
        LayoutParams.alignParentLeftRight(subview: textEdit, marginLeft: 12, marginRight: 12)
        
        contentLayout = UIView()
        self.addSubview(contentLayout);
        LayoutParams.alignParentLeftRight(subview: contentLayout)
        
        addAnotherLayout = UIView()
        self.addSubview(addAnotherLayout);
        LayoutParams.alignParentLeftRight(subview: addAnotherLayout)
        LayoutParams.setHeight(view: addAnotherLayout, height: 48)
        
        let addAnotherLayoutInner = UIView()
        addAnotherLayout.addSubview(addAnotherLayoutInner)
        LayoutParams.alignParentTopBottom(subview: addAnotherLayoutInner)
        LayoutParams.centerParentHorizontal(subview: addAnotherLayoutInner)
        
        addAnotherImage = UIImageViewX()
        addAnotherImage.alpha = 0.5
        addAnotherLayoutInner.addSubview(addAnotherImage);
        LayoutParams.alignParentLeft(subview: addAnotherImage)
        LayoutParams.centerParentVertical(subview: addAnotherImage)
        LayoutParams.setWidth(view: addAnotherImage, width: 24)
        LayoutParams.setHeight(view: addAnotherImage, height: 24)
        
        addAnotherText = UILabelX()
        addAnotherText.textColor = Color.halfBlack
        addAnotherText.font = ViewController.typefaceMI(17)
        addAnotherLayoutInner.addSubview(addAnotherText);
        LayoutParams.alignParentRight(subview: addAnotherText)
        LayoutParams.centerParentVertical(subview: addAnotherText)
        LayoutParams.stackHorizontal(leftView: addAnotherImage, rightView: addAnotherText, margin: 4)
        
        quickView = VerticalLinearLayout()
        LayoutParams.alignParentLeftRight(subview: quickView)
        LayoutParams.alignParentBottom(subview: quickView, margin: bottomH)
        quickView.backgroundColor = Color.WHITE
        
        quickHeader = HeaderView();
        quickHeader.populate(CurrentUser.user(), nil, nil);
        quickHeader.isHiddenX = true
        quickView.addSubview(quickHeader);
        
        quickEdit = LabeledEditText(label: "Write your comment here", fadingLabel: true, textSize: 17, labelSize: 14, errorSize: 11);
        quickView.addSubview(quickEdit, marginTop: -6);
        LayoutParams.alignParentLeftRight(subview: quickEdit, marginLeft: 12, marginRight: 12)
        
        quickMessage = UILabelX()
        quickMessage.setInsets(UIEdgeInsets(top: 8, left: 8, bottom: 0 /*special iOS*/, right: 8))
        ContentCreator.setUpBoldThemeStyle(quickMessage, size: 14, italics: true);
        quickMessage.textAlignment = .center
        quickView.addSubview(quickMessage, marginTop: -6);
        LayoutParams.alignParentLeftRight(subview: quickMessage)
        
        bottomView = BasicViewGroup();
        bottomView.backgroundColor = Color.WHITE
        LayoutParams.alignParentLeftRight(subview: bottomView)
        LayoutParams.setHeight(view: bottomView, height: bottomH)
        LayoutParams.alignParentBottom(subview: bottomView)
        
        //not necessary for iOS
        /*bottomView.callback = BasicOnLayoutCallback(execute: {
            if let updateBottomCallback = self.updateBottomCallback{
                Async.run(SyncInterface(runTask: {
                    updateBottomCallback.execute();
                }))
            }
        })*/
        
        bottomAttachLayout = BasicViewGroup();
        
        let attachText = UILabelX()
        attachText.text = "Attach Content"
        attachText.textColor = Color.BLACK
        attachText.font = ViewController.typefaceMI(17)
        attachText.alpha = 0.5
        bottomAttachLayout.addSubview(attachText);
        Layout.wrapW(attachText, l: 8, t: 0, height: bottomH);
        
        for i in 1 ..< 4{
            let item = UIImageViewX()
            item.image = Misc.contentTypeImage(i)
            item.alpha = 0.5
            bottomAttachLayout.addSubview(item);
            Layout.exact(item, l: Measure.w(attachText) + 12 + CGFloat(i - 1) * 24, t: (bottomH - 24) / 2, width: 24, height: 24);
        }
        
        let more = UIImageViewX()
        more.image = #imageLiteral(resourceName: "more")
        more.alpha = 0.5
        bottomAttachLayout.addSubview(more);
        Layout.exact(more, l: Measure.w(attachText) + 12 + 72, t: (bottomH - 24) / 2, width: 24, height: 24);
        
        bottomView.addSubview(bottomAttachLayout);
        Layout.exact(bottomAttachLayout, width: 12 + Measure.w(attachText) + 96 + 8, height: bottomH);
        
        bottomRemoveLayout = BasicViewGroup();
        
        let item = UIImageViewX()
        item.image = #imageLiteral(resourceName: "clear")
        item.alpha = 0.5
        bottomRemoveLayout.addSubview(item);
        Layout.exact(item, l: 8, t: (bottomH - 24) / 2, width: 24, height: 24);
        
        bottomRemoveText = UILabelX()
        bottomRemoveText.textColor = Color.halfBlack
        bottomRemoveText.font = ViewController.typefaceMI(17)
        bottomRemoveLayout.addSubview(bottomRemoveText);
        
        bottomView.addSubview(bottomRemoveLayout);
        
        sendText = UILabelX()
        sendText.setInsets(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
        sendText.text = (postId == nil) ? "Post" : "Comment"
        ContentCreator.setUpBoldThemeStyle(sendText, size: 20, italics: true);
        bottomView.addSubview(sendText);
        Layout.wrapWLeft(sendText, r: context.screenWidth, t: 0, height: bottomH);
        
        updateBottomView();
        
        textEdit.editText.onTextChanged.append({ text in
            print("textEditChanged: " + text)
            if (text != self.quickEdit.getText()) {
                self.quickEdit.setText(text)
            }
            
            if(text != ""){
                self.textEdit.setError("");
                self.quickEdit.setError("");
            }
        })
        
        quickEdit.editText.onTextChanged.append({ text in
            print("quickEditChanged: " + text)
            if text != self.textEdit.getText(){
                self.textEdit.setText(text)
            }
        })
        
        TouchController.setUniversalOnTouchListener(addAnotherLayout, allowSpreadMovement: true, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
            self.affirmedNewContent();
        }))
        
        TouchController.setUniversalOnTouchListener(bottomAttachLayout, allowSpreadMovement: false, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
            self.attachContent();
        }))
        
        TouchController.setUniversalOnTouchListener(bottomRemoveLayout, allowSpreadMovement: false, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
            self.contentLayoutInner.removeAllViews();
            for callback in self.preSendCallback{
                callback.onDestroy()
            }
            self.preSendCallback.removeAll()
            self.updateBottomView();
        }))
        
        TouchController.setUniversalOnTouchListener(sendText, allowSpreadMovement: false, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
            self.send();
        }))
    }
    
    func updateBottomView(){
        if(contentLayoutInner.subviews.count == 0){
            bottomAttachLayout.isHiddenX = false
            bottomRemoveLayout.isHiddenX = true
            quickMessage.isHiddenX = true
            contentType = -1;
        }else {
            bottomAttachLayout.isHiddenX = true
            bottomRemoveLayout.isHiddenX = false
            quickMessage.isHiddenX = false
            if(contentLayoutInner.subviews.count > 1){
                bottomRemoveText.text = "Remove " + Misc.contentTypeName(contentType) + "s"
                quickMessage.text = "Scroll down to view " + String(contentLayoutInner.subviews.count) + " attachments."
            }else{
                bottomRemoveText.text = "Remove " + Misc.contentTypeName(contentType)
                quickMessage.text = "Scroll down to view 1 attachment."
            }
            Layout.wrapW(bottomRemoveText, l: 32, t: 0, height: bottomH);
            Layout.exact(bottomRemoveLayout, width: Measure.w(bottomRemoveText) + 44, height: bottomH);
            addAnotherImage.image = Misc.contentTypeImage(contentType)
            addAnotherText.text = "Add Another " + Misc.contentTypeName(contentType)
        }
        
        if(contentLayoutInner.subviews.count > 0 && contentLayoutInner.subviews.count < 3){
            addAnotherLayout.isHiddenX = false
        }else{
            addAnotherLayout.isHiddenX = true
        }
        
        let _ = Measure.wrapH(quickView, width: Measure.w(quickView));
        
        //not necessary for iOS
        /*if let updateBottomCallback = updateBottomCallback{
            Async.run(SyncInterface(runTask: updateBottomCallback.execute))
        }*/
    }
    
    func attachContent(){
        let layout = VerticalLinearLayout()
        
        layout.setInsets(UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)) //iOS only
        
        let textView = UILabelX()
        textView.text = "Note: A post may contain only one type of content, but may contain up to three attachments of that type."
        textView.font = ViewController.typefaceR(14)
        textView.textColor = Color.BLACK
        textView.alpha = 0.5
        textView.setInsets(UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8))
        textView.textAlignment = .center
        layout.addSubview(textView);
        LayoutParams.alignParentLeftRight(subview: textView)
        
        for i in 1 ..< 6{
            
            if(i == 2 || i == 4){ //not yet supported
                continue;
            }
            
            let item = UILabelX()
            item.setInsets(UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 0))
            item.text = "Attach " + Misc.contentTypeName(i) + "(s)"
            item.textColor = Color.BLACK
            item.font = ViewController.typefaceMI(17)
            item.alpha = 0.5
            layout.addSubview(item, marginTop: i == 1 ? 0 : 10);
            LayoutParams.alignParentLeftRight(subview: item)
            LayoutParams.setHeight(view: item, height: 48)
            
            let icon = UIImageViewX()
            icon.image = Misc.contentTypeImage(i)
            icon.alpha = 0.5
            layout.addSubview(icon, marginTop: -34);
            LayoutParams.setWidthHeight(view: icon, width: 24, height: 24)
            LayoutParams.alignParentLeft(subview: icon, margin: 24)
            
            TouchController.setUniversalOnTouchListener(item, allowSpreadMovement: false, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
                Dialog.animateHide();
                self.contentType = i;
                self.affirmedNewContent();
            }))
        }
        
        Dialog.showDialog(title: "Choose Content Type", contentView: layout, negativeText: "Cancel", positiveText: nil, positiveCallback: nil);
    }
    
    func affirmedNewContent(){
        switch (contentType){
        case 1:
            self.context.pictureCallback = PictureIntentCallback(success: { image in
                self.setUpNewContent(incomingMedia: image);
            })
            self.context.pictureIntent(requestCode: self.context.POST_PICTURE);
            break;
        case 2:
            self.context.videoCallback = VideoIntentCallback(success: {i in
                self.setUpNewContent(incomingMedia: i)
            })
            self.context.videoIntent(requestCode: self.context.POST_VIDEO);
            break;
        case 4:
            break;
        default:
            setUpNewContent(incomingMedia: nil);
            break;
        }
    }
    
    func setUpNewContent(incomingMedia:Any?){
        
        let layout = UIView()
        var callback:PreSendCallback!
        
        switch (contentType){
        case 1:
            if(!(incomingMedia is UIImage)){
                return;
            }
            
            let image = incomingMedia as! UIImage
            
            if contentLayoutInner.subviews.count == 0 || !(contentLayoutInner is HorizontalWeightedLinearLayout){
                contentLayoutInner.removeFromSuperview()
                contentLayoutInner = HorizontalWeightedLinearLayout()
                contentLayout.addSubview(contentLayoutInner)
                LayoutParams.alignParentLeftRight(subview: contentLayoutInner)
                LayoutParams.alignParentTopBottom(subview: contentLayoutInner)
            }
            
            let imageView = UIImageViewX()
            imageView.backgroundColor = Color.main_background
            layout.addSubview(imageView);
            LayoutParams.alignParentTopBottom(subview: imageView)
            LayoutParams.centerParentHorizontal(subview: imageView)
            
            NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: CGFloat(image.size.width) / CGFloat(image.size.height), constant: 0).isActive = true
            NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .lessThanOrEqual, toItem: layout, attribute: .width, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: context.screenHeight / 2).isActive = true
            
            var processing = true
            var encoded:Data!
            
            Async.run(Async.PRIORITY_IMPORTANT, AsyncSyncInterface(runTask: {
                encoded = Misc.encodeImage(image)
            }, afterTask: {
                imageView.backgroundColor = .clear
                imageView.image = Misc.decodeImage(encoded)
                processing = false
            }))
            
            callback = PreSendCallback(execute: {
                
                if processing{
                    Async.toast("Please wait for your image to process.  It should only take a moment!", true);
                    return false;
                }
                
                self.media.append(encoded)
                
                let dimens = [Int(image.size.width), Int(image.size.height)]
                self.mediaDimens.append(dimens);
                
                let width = min(Measure.w(imageView), Measure.w(imageView) * 512 / self.context.screenWidth);
                
                let thumb = image.scaleImage(toSize: CGSize(width: width, height: width * image.size.height / image.size.width))
                self.thumbs.append(Misc.encodeImage(thumb)!);
                
                let thumbDimens = [Int(thumb.size.width), Int(thumb.size.height)]
                self.thumbsDimens.append(thumbDimens);
                
                return true;
            }, onDestroy: {
                //not needed in iOS
            })
            
            (contentLayoutInner as! HorizontalWeightedLinearLayout).addSubview(layout, weight: image.size.width / image.size.height)
            
            break;
        case 2:
            
            break;
        case 3:
            if contentLayoutInner.subviews.count == 0 || !(contentLayoutInner is VerticalLinearLayout){
                contentLayoutInner.removeFromSuperview()
                contentLayoutInner = VerticalLinearLayout()
                contentLayout.addSubview(contentLayoutInner)
                LayoutParams.alignParentLeftRight(subview: contentLayoutInner)
                LayoutParams.alignParentTopBottom(subview: contentLayoutInner)
            }
            
            LayoutParams.alignParentLeftRight(subview: layout)
            
            let linkEdit = LabeledEditField(label: "Type link URL here", fadingLabel: true, textSize: 17, labelSize: 14, errorSize: 11);
            linkEdit.editText.keyboardType = .URL
            linkEdit.editText.autocorrectionType = .no
            layout.addSubview(linkEdit);
            LayoutParams.alignParentLeftRight(subview: linkEdit, marginLeft: 12, marginRight: 32 + 8)
            LayoutParams.alignParentTop(subview: linkEdit)
            //TODO necessary? linkEdit.editText.getParent().requestDisallowInterceptTouchEvent(true);
            
            let defaultTitle = "Title of Website Will Display Here";
            let defaultLink = "Complete URL Will Display Here";
            let loadingTitle = "Loading Website Title...";
            
            let titleAndLinkView = TitleAndLinkView(colorTheme: TitleAndLinkView.LINK, width: context.screenWidth);
            titleAndLinkView.populate(title: defaultTitle, link: defaultLink);
            layout.addSubview(titleAndLinkView);
            LayoutParams.alignParentLeftRight(subview: titleAndLinkView)
            LayoutParams.stackVertical(topView: linkEdit, bottomView: titleAndLinkView)
            LayoutParams.setHeight(view: titleAndLinkView, height: TitleAndLinkView.H)
            
            let webViewHolder = BasicViewGroup();
            layout.addSubview(webViewHolder);
            LayoutParams.alignParentLeft(subview: webViewHolder)
            LayoutParams.setWidthHeight(view: webViewHolder, width: context.screenWidth, height: context.screenWidth * 9 / 16)
            LayoutParams.stackVertical(topView: titleAndLinkView, bottomView: webViewHolder)
            
            let webView = EnhancedWebView();
            webView.isHiddenX = true
            webViewHolder.addSubview(webView);
            Layout.exact(webView, width: context.screenWidth, height: context.screenWidth * 9 / 16);
            
            let s1 = ContentCreator.shadow(top: true, alpha: 0.1);
            webViewHolder.addSubview(s1);
            Layout.exact(s1, width: context.screenWidth, height: 5);
            
            let s2 = ContentCreator.shadow(top: false, alpha: 0.1);
            webViewHolder.addSubview(s2);
            Layout.exactUp(s2, l: 0, b: context.screenWidth * 9 / 16, width: context.screenWidth, height: 5);
            
            let previewCover = BasicViewGroup();
            previewCover.backgroundColor = Color.view_touch
            layout.addSubview(previewCover);
            LayoutParams.alignParentLeft(subview: previewCover)
            LayoutParams.setWidthHeight(view: previewCover, width: context.screenWidth, height: context.screenWidth * 9 / 16)
            LayoutParams.alignTop(view1: previewCover, view2: webViewHolder)
            
            TouchController.setUniversalOnTouchListener(previewCover, allowSpreadMovement: true);
            
            let previewProgressBar = UIActivityIndicatorView()
            previewProgressBar.color = Color.linkColor
            previewProgressBar.isHiddenX = true
            previewCover.addSubview(previewProgressBar);
            Layout.exact(previewProgressBar, l: (context.screenWidth - 48) / 2, t: (context.screenWidth * 9 / 16 - 48) / 2, width: 48, height: 48);
            previewProgressBar.startAnimating()
            
            let underPreview = UILabelX()
            underPreview.textAlignment = .center
            underPreview.text = "The website preview will appear above this text.  It will appear to other users exactly as it does here, so feel free to scroll or click around to show the exact content you wish to show."
            underPreview.textColor = Color.linkColor
            underPreview.font = ViewController.typefaceR(14)
            layout.addSubview(underPreview);
            LayoutParams.alignParentLeftRight(subview: underPreview, marginLeft: 8, marginRight: 8)
            LayoutParams.stackVertical(topView: webViewHolder, bottomView: underPreview, margin: 2)
            LayoutParams.alignParentBottom(subview: underPreview, margin: 8)
            
            webView.setOnProgressChanged(onProgressChanged: { newProgress in
                
                previewProgressBar.isHiddenX = false
                
                if (newProgress == 1.0) {
                    titleAndLinkView.populate(title: webView.title ?? "", link: webView.url?.absoluteString ?? "", callback: ClickCallback(execute: {
                        let _ = WindowWithWebView(link: webView.url?.absoluteString ?? "", title: webView.title ?? "");
                    }));
                    previewCover.isHiddenX = true
                } else {
                    titleAndLinkView.populate(title: loadingTitle, link: webView.url!.absoluteString);
                    previewCover.isHiddenX = false
                }
            })
            
            linkEdit.editText.onTextChanged.append({ text in
                if (text == "") {
                    titleAndLinkView.populate(title: defaultTitle, link: defaultLink);
                    webView.isHiddenX = true
                    previewCover.isHiddenX = false
                    previewProgressBar.isHiddenX = true
                } else {
                    webView.isHiddenX = false
                    webView.load(URLRequest(url: URL(string: Misc.linkifyLink(text)) ?? URL(string: "about:blank")!))
                }
            })
            
            if(incomingMedia != nil && incomingMedia is String){
                linkEdit.setText(incomingMedia as! String);
            }
            
            callback = PreSendCallback(execute: {
                if(linkEdit.getText() == ""){
                    return true;
                }
                if(previewCover.isHiddenX) {
                    self.contentText.append(webView.url?.absoluteString ?? "Error loading url");
                    self.contentTitle.append(webView.title ?? "Error loading title")
                    self.media.append(Misc.encodeImage(UIImage(view: webViewHolder).scaleImage(toSize: CGSize(width: 512, height: 288)))!)
                    let dimens = [512, 288]
                    self.mediaDimens.append(dimens);
                    return true;
                }else{
                    Async.toast("Please wait until the link preview loads before posting.", true);
                    return false;
                }
            }, onDestroy: {
                webView.load(URLRequest(url: URL(string: "about:blank")!))
            })
            
            contentLayoutInner.addSubview(layout)
            
            break;
        case 4:
            break;
        case 5:
            if contentLayoutInner.subviews.count == 0 || !(contentLayoutInner is VerticalLinearLayout){
                contentLayoutInner.removeFromSuperview()
                contentLayoutInner = VerticalLinearLayout()
                contentLayout.addSubview(contentLayoutInner)
                LayoutParams.alignParentLeftRight(subview: contentLayoutInner)
                LayoutParams.alignParentTopBottom(subview: contentLayoutInner)
            }
            
            LayoutParams.alignParentLeftRight(subview: layout)
            
            let youtubeLinkEdit = LabeledEditField(label: "Type YouTube URL or video ID here", fadingLabel: true, textSize: 17, labelSize: 14, errorSize: 11);
            youtubeLinkEdit.editText.keyboardType = .URL
            youtubeLinkEdit.editText.autocorrectionType = .no
            layout.addSubview(youtubeLinkEdit);
            LayoutParams.alignParentLeftRight(subview: youtubeLinkEdit, marginLeft: 12, marginRight: 32 + 8)
            LayoutParams.alignParentTop(subview: youtubeLinkEdit)
            //TODO necessary? youtubeLinkEdit.editText.getParent().requestDisallowInterceptTouchEvent(true);
            
            let youTubeVideoView = YouTubeVideoView(width: context.screenWidth);
            layout.addSubview(youTubeVideoView);
            LayoutParams.setWidthHeight(view: youTubeVideoView, width: context.screenWidth, height: context.screenWidth * 9 / 16 + 50)
            LayoutParams.alignParentLeft(subview: youTubeVideoView)
            LayoutParams.stackVertical(topView: youtubeLinkEdit, bottomView: youTubeVideoView, margin: 4)
            LayoutParams.alignParentBottom(subview: youTubeVideoView)
            
            youtubeLinkEdit.editText.onTextChanged.append({ text in
                var id = text
                if (id.indexOf("&") != -1) {
                    id = id.substring(0, id.indexOf("&"));
                }
                id = id.substring(max(id.lastIndexOf("/"), id.lastIndexOf("=")) + 1);
                youTubeVideoView.populate(videoId: id);
            })
            
            callback = PreSendCallback(execute: {
                if(youtubeLinkEdit.getText() == ""){
                    return true;
                }
                
                if(!youTubeVideoView.loaded){
                    Async.toast("Please wait until the YouTube video preview loads before posting.", true);
                    return false;
                }
                
                self.contentText.append(youTubeVideoView.m_videoId);
                self.contentTitle.append(youTubeVideoView.m_title);
                self.media.append(youTubeVideoView.m_thumbnail);
                let dimens = [512, 288]
                self.mediaDimens.append(dimens);
                
                return true;
            }, onDestroy: {
                
            })
            
            contentLayoutInner.addSubview(layout)
            
            break;
        default:break;
        }
        
        let clear = UIImageViewX()
        clear.setInsets(UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
        clear.image = #imageLiteral(resourceName: "clear")
        layout.addSubview(clear);
        LayoutParams.setWidthHeight(view: clear, width: 32, height: 32)
        LayoutParams.alignParentTop(subview: clear, margin: 8)
        LayoutParams.alignParentRight(subview: clear, margin: 8)
        
        //TODO ensure you've covered this! contentLayoutInner.addSubview(layout);
        
        preSendCallback.append(callback);
        
        TouchController.setUniversalOnTouchListener(clear, allowSpreadMovement: true, onOffCallback: OnOffCallback(on: {
            clear.backgroundColor = Color.view_touchOpaque
        }, off: {
            clear.backgroundColor = Color.WHITE
        }), clickCallback: ClickCallback(execute: {
            layout.removeFromSuperview()
            callback.onDestroy();
            for i in 0 ..< self.preSendCallback.count{
                if self.preSendCallback[i] === callback{
                    self.preSendCallback.remove(at: i)
                    break;
                }
            }
            self.updateBottomView();
        }))
        
        updateBottomView();
        
        if let newContentCallback = newContentCallback{
            Async.run(SyncInterface(runTask: {
                newContentCallback.execute()
            }))
        }
    }
    
    func send(){
        
        contentTitle.removeAll()
        contentText.removeAll()
        media.removeAll()
        mediaDimens.removeAll()
        
        if (textEdit.getText() == "") {
            Toast.makeText(context, "Every post on Uplift must contain some text.  Express yourself!", Toast.LENGTH_LONG)
            textEdit.setError("Every post on Uplift must contain text");
            quickEdit.setError("Every post on Uplift must contain text");
        } else {
            sendText.setTouchEnabled(false);
            sendText.textColor = Color.halfBlack
            
            Async.run(Async.PRIORITY_IMPORTANT, AsyncSyncSuccessInterface(runTask: {
                for callback in self.preSendCallback{
                    if(!callback.execute()){
                        return false;
                    }
                }
                return true;
            }, afterTask: { success, message in
                if(!success){
                    self.sendText.setTouchEnabled(true);
                    self.sendText.textColor = Color.theme_bold
                    return;
                }
                
                if let postId = self.postId{
                    Upload.sendComment(postId, self.textEdit.getText(), self.contentType, self.contentTitle, self.contentText, self.media, self.mediaDimens, self.thumbs, self.thumbsDimens);
                    self.textEdit.setText("");
                    self.contentLayoutInner.removeAllViews();
                    self.preSendCallback.removeAll()
                    
                    self.context.clearAllFocus();
                    
                    self.sendText.setTouchEnabled(true);
                    self.sendText.textColor = Color.theme_bold
                    
                    self.updateBottomView();
                }else {
                    Upload.sendPost(self.textEdit.getText(), self.contentType, self.contentTitle, self.contentText, self.media, self.mediaDimens, self.thumbs, self.thumbsDimens);
                    WindowBase.topShownWindow()!.hideFrame(send: true);
                }
            }))
        }
    }
}

class ComposeWebViewDelegate:NSObject, UIWebViewDelegate{
    override init(){
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
    }
}
