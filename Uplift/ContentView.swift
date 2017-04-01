//
//  ContentView.swift
//  Uplift
//
//  Created by Adam Cobb on 11/9/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class ContentView:VerticalLinearLayout{
    
    weak var context:ViewController! = ViewController.context
    
    var textView:UILabelX!
    
    convenience init(_ textSelectable:Bool){
    
        self.init(coder: nil)
        
    textView = UILabelX()
        textView.setInsets(UIEdgeInsets(top: 2, left: 16, bottom: 2, right:16))
        textView.textColor = Color.textColor
        textView.font = ViewController.typefaceR(17)
        textView.numberOfLines = 0
    }
    
    func populate(postOrComment:PostOrCommentObject, user:UserObject?){
        
        if postOrComment.getContentType() == -1{ //guaranteed local only
            self.removeAllViews()
            
            self.textView.text = postOrComment.getText()
            self.addSubview(self.textView)
            LayoutParams.alignParentLeftRight(subview: self.textView)
            return
        }
        
        Async.run(Async.PRIORITY_IMPORTANT, AsyncSyncInterface(runTask: {
            let _ = postOrComment.getThumbs()
        }, afterTask: {
            if let superview = self.superview{
                superview.bringSubview(toFront: self)
            }
            
            var width = self.context.screenWidth!
            if postOrComment is CommentObject{
                width -= 16 + 72;
            }
            
            self.removeAllViews()
            
            self.textView.text = postOrComment.getText()
            self.addSubview(self.textView)
            LayoutParams.alignParentLeftRight(subview: self.textView)
            
            let contentTitle = postOrComment.getContentTitle();
            let contentText = postOrComment.getContentText();
            let media = postOrComment.getThumbs();
            let mediaDimens = postOrComment.getThumbsDimens();
            
            switch (postOrComment.getContentType()){
            case 1:
                let contentView = HorizontalWeightedLinearLayout()
                LayoutParams.alignParentLeftRight(subview: contentView)
                self.addSubview(contentView, marginTop: 4)
                
                for i in 0 ..< media.count{
                    
                    let layout = UIView()
                    contentView.addSubview(layout, weight: CGFloat(mediaDimens[i][0]) / CGFloat(mediaDimens[i][1]))
                    
                    let imageView = RecyclerImageView(media[i], mediaDimens[i]);
                    LayoutParams.alignParentTopBottom(subview: imageView)
                    LayoutParams.centerParentHorizontal(subview: imageView)
                    layout.addSubview(imageView);
                    
                    NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: CGFloat(mediaDimens[i][0]) / CGFloat(mediaDimens[i][1]), constant: 0).isActive = true
                    NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .lessThanOrEqual, toItem: layout, attribute: .width, multiplier: 1, constant: 0).isActive = true
                    NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.context.screenHeight / 2).isActive = true
                    
                    let cover = UIView()
                    LayoutParams.alignLeftRight(view1: cover, view2: imageView)
                    LayoutParams.alignTopBottom(view1: cover, view2: imageView)
                    layout.addSubview(cover);
                    
                    TouchController.setUniversalOnTouchListener(cover, allowSpreadMovement: true, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
                        let _ = WindowWithImages(name: user!.getName()!, images: postOrComment.getThumbs(), dimens: postOrComment.getMediaDimens(), startImage: i, startImageView: imageView, highQualityCallback: GetImagesCallback(executeSync: {
                            return postOrComment.getMedia()
                        }))
                    }))
                }
                
                break;
            case 2:
                break;
            case 3:
                
                for i in 0 ..< media.count{
                    
                    let link = contentText[i]
                    let title = contentTitle[i]
                    
                    let previewHeight = width * 9 / 16;
                    
                    let layout = BasicViewGroup();
                    LayoutParams.alignParentLeft(subview: layout)
                    LayoutParams.setWidth(view: layout, width: width)
                    LayoutParams.setHeight(view: layout, height: TitleAndLinkView.H + previewHeight)
                    self.addSubview(layout, marginTop: 4);
                    
                    let titleAndLinkView = TitleAndLinkView(colorTheme: TitleAndLinkView.LINK, width: width);
                    titleAndLinkView.populate(title: title, link: link, colored: true)
                    layout.addSubview(titleAndLinkView);
                    Layout.exact(titleAndLinkView, width: width, height: TitleAndLinkView.H);
                    
                    let preview = RecyclerImageView(media[i], mediaDimens[i]);
                    layout.addSubview(preview);
                    Layout.exact(preview, l: 0, t: TitleAndLinkView.H, width: width, height: previewHeight);
                    
                    let cover = UIView()
                    layout.addSubview(cover);
                    Layout.exact(cover, width: width, height: TitleAndLinkView.H + previewHeight);
                    
                    TouchController.setUniversalOnTouchListener(cover, allowSpreadMovement: true, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
                        let _ = WindowWithWebView(link: link, title: title);
                    }))
                    
                }
                
                break;
            case 4:
                break;
            case 5:
                for i in 0 ..< media.count{
                    let youTubeVideoView = YouTubeVideoView(width: width)
                    LayoutParams.alignParentLeft(subview: youTubeVideoView)
                    self.addSubview(youTubeVideoView, marginTop: 4);
                    youTubeVideoView.populate(videoId: contentText[i], title: contentTitle[i], thumbnail: media[i], thumbnailDimens: mediaDimens[i]);
                }
                break;
            default: break;
            }
        }))
    }
}
