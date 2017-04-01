//
//  WindowWithWebView.swift
//  Uplift
//
//  Created by Adam Cobb on 12/29/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class WindowWithWebView: WindowBase {
    var linkH:CGFloat!
    
    var webView:EnhancedWebView!
    var back:UIImageViewX!, forward:UIImageViewX!, refresh:UIImageViewX!
    var linkView:ScrollingTextView!
    
    init(link:String, title:String){
        super.init()
        
    linkH = 36;
    
    let link = Misc.linkifyLink(link);
    
    buildWebView(link: link);
        buildExpand(link: link);
    buildTitle(title);
    buildFrame();
        
        LayoutParams.alignParentLeftRight(subview: expandView!)
        LayoutParams.setHeight(view: expandView!, height: expandH + linkH)
        LayoutParams.alignParentTop(subview: expandView!, margin: topH)
        
        LayoutParams.alignParentLeftRight(subview: content)
        LayoutParams.alignParentTopBottom(subview: content, marginTop: topH + linkH, marginBottom: 0)
    showFrame();
    }
    
    var refreshing = false;
    
    func buildWebView(link:String){
    webView = EnhancedWebView();
        
        webView.setOnProgressChanged(onProgressChanged: { newProgress in
            let rounds:Int64 = 7200;
            let period:Int64 = 500;
            if (newProgress == 1.0) {
                if (self.refreshing) {
                    
                    self.refreshing = false;
                    
                    Async.run(period - 50, SyncInterface(runTask: {
                    
                    self.refresh.animate().cancel(); //needed fsr
                        self.refresh.layer.removeAllAnimations()
                    
                    let _ = self.refresh.animate().rotation(360).alpha(1).setDuration(Int64(CGFloat(period) * 2)).setInterpolator(.decelerate).setListener( AnimatorListener(onAnimationEnd: {
                        self.refresh.setTouchEnabled(true)
                    }))
                    }))
                }
            } else {
                if (!self.refreshing) {
                    self.refreshing = true;
                    let _ = self.refresh.animate().rotationBy(180).alpha(0.4).setDuration(period).setInterpolator(.accelerate)
                    
                    Async.run(period - 50, SyncInterface(runTask: {
                        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
                        animation.byValue = CGFloat(rounds) * 2 * CGFloat(M_PI)
                        animation.duration = Double(period * rounds) / 1000
                        animation.isCumulative = true
                        animation.repeatCount = 1
                        
                        self.refresh.layer.add(animation, forKey: "rotationAnimation")
                    }))
                    
                    self.refresh.setTouchEnabled(false)
                }
            }
            
            self.titleTextView.text = self.webView.title ?? ""
            
            self.linkView.text = self.webView.url?.absoluteString ?? ""
            
            if (self.webView.canGoBack) {
                self.back.alpha = 1;
                self.back.setTouchEnabled(true)
            } else {
                self.back.alpha = 0.2
                self.back.setTouchEnabled(false)
            }
            
            if (self.webView.canGoForward) {
                self.forward.alpha = 1
                self.forward.setTouchEnabled(true)
            } else {
                self.forward.alpha = 0.2
                self.forward.setTouchEnabled(false)
            }
        })
        
        Async.run(SyncInterface(runTask: {
            //these touch listeners are just in swift
            TouchController.setUniversalOnTouchListener(self.refresh, allowSpreadMovement: false, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
                self.webView.reload();
            }));
            
            TouchController.setUniversalOnTouchListener(self.back, allowSpreadMovement: false, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
                self.webView.goBack()
            }))
            
            TouchController.setUniversalOnTouchListener(self.forward, allowSpreadMovement: false, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
                self.webView.goForward()
            }))
            
            //this is NOT just in swift
            self.webView.load(URLRequest(url: URL(string: link)!))
        }))

content = webView;
}

    func buildExpand(link:String) {
    super.buildExpand();
        
        let expandView = self.expandView!
    
    let linkBack = UIView()
    linkBack.backgroundColor = Color.title_extension
    expandView.addSubview(linkBack);
    Layout.exact(linkBack, l: 0, t: expandH, width: context.screenWidth, height: linkH);
    
    back = UIImageViewX()
    back.image = #imageLiteral(resourceName: "left")
    expandView.addSubview(back);
    Layout.exact(back, l: 0, t: expandH, width: linkH, height: linkH);
    
    refresh = UIImageViewX()
    refresh.image = #imageLiteral(resourceName: "refresh")
    expandView.addSubview(refresh);
    Layout.exact(refresh, l: linkH, t: expandH, width: linkH, height: linkH);
    
    forward = UIImageViewX()
    forward.image = #imageLiteral(resourceName: "right")
    expandView.addSubview(forward);
    Layout.exact(forward, l: linkH * 2, t: expandH, width: linkH, height: linkH);
    
    linkView = ScrollingTextView()
    linkView.text = link
    linkView.label.textColor = Color.BLACK
        linkView.label.font = ViewController.typefaceM(14)
    linkView.alpha = 0.6
    expandView.addSubview(linkView);
    let linkLeft = linkH * 3 + 4;
    Layout.exact(linkView, l: linkLeft, t: expandH, width: context.screenWidth - linkLeft - 4, height: linkH);
    
    let externallyIcon = UIImageViewX()
        externallyIcon.image = #imageLiteral(resourceName: "externally_theme")
    expandView.addSubview(externallyIcon);
    
    let externallyText = UILabelX()
    externallyText.textColor = Color.theme
        externallyText.font = ViewController.typefaceMI(17)
    externallyText.text = "Open Externally"
        externallyText.setInsets(UIEdgeInsets(top: 0, left: expandH - 4, bottom: 0, right: 12))
    expandView.addSubview(externallyText);
    Layout.wrapWLeft(externallyText, r: context.screenWidth, t: 0, height: expandH);
    
    Layout.exact(externallyIcon, l: context.screenWidth - Measure.w(externallyText), t: 0, width: expandH, height: expandH);
    
    let copyIcon = UIImageViewX()
    copyIcon.image = #imageLiteral(resourceName: "copy_theme")
    expandView.addSubview(copyIcon);
    
    let copyText = UILabelX()
    copyText.textColor = Color.theme
        copyText.font = ViewController.typefaceMI(17)
    copyText.text = "Copy Link"
        copyText.setInsets(UIEdgeInsets(top: 0, left: expandH - 4, bottom: 0, right: 12))
    expandView.addSubview(copyText);
    Layout.wrapWLeft(copyText, r: context.screenWidth - Measure.w(externallyText), t: 0, height: expandH);
    
    Layout.exact(copyIcon, l: (CGFloat(context.screenWidth) - Measure.w(externallyText)) - Measure.w(copyText), t: 0, width: expandH, height: expandH);
    
        TouchController.setUniversalOnTouchListener(externallyText, allowSpreadMovement: false, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
            UIApplication.shared.open(self.webView.url ?? URL(string: "about:blank")!, options: [:], completionHandler: nil)
        }))
        
        TouchController.setUniversalOnTouchListener(copyText, allowSpreadMovement: false, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
            UIPasteboard.general.string = self.webView.url?.absoluteString ?? ""
            Toast.makeText(self.context, "Link copied to clipboard.", Toast.LENGTH_SHORT)
        }))
    
    let bottomHighlight = UIView()
    bottomHighlight.backgroundColor = Color.title_highlight
    expandView.addSubview(bottomHighlight);
    Layout.exactUp(bottomHighlight, l: 0, b: expandH + linkH, width: context.screenWidth, height: 1);
}

    override func hideFrame(send:Bool){
    super.hideFrame(send: send);
        Async.run(200, SyncInterface(runTask: {
            self.webView.load(URLRequest(url: URL(string: "about:blank")!))
        }
    ))
}
}
