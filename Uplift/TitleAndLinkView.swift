//
//  TitleAndLinkView.swift
//  Uplift
//
//  Created by Adam Cobb on 11/7/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class TitleAndLinkView: BasicViewGroup{
    
    var m_titleView:UILabelX!, m_linkView:UILabelX!
    var m_openImage:UIImageView!
    var m_cover:UIView!
    
    static var H:CGFloat!
    let H:CGFloat = TitleAndLinkView.H
    
    var m_colorTheme:Int!
    static let LINK = 1;
    static let YOUTUBE = 2;
    
    required init(coder: NSCoder?) {
        super.init(coder: coder)
    }
    
    convenience init(colorTheme:Int, width:CGFloat){
        self.init(coder: nil)
        
        m_colorTheme = colorTheme
        
        m_titleView = UILabelX()
        m_titleView.font = ViewController.typefaceM(17)
        m_titleView.numberOfLines = 1
        m_titleView.lineBreakMode = .byClipping
        addSubview(m_titleView);
        Layout.wrapH(m_titleView, l: 46, t: 3, width: width - (46 + 4));
        
        let titleMask = CAGradientLayer()
        titleMask.frame = CGRect(origin: .zero, size: m_titleView.measuredSize)
        titleMask.startPoint = CGPoint(x: 0, y: 0.5)
        titleMask.endPoint = CGPoint(x: 1, y: 0.5)
        titleMask.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
        titleMask.locations = [0.9, 1]
        m_titleView.layer.mask = titleMask
        
        m_linkView = UILabelX()
        m_linkView.font = ViewController.typefaceR(14)
        m_linkView.numberOfLines = 1
        m_linkView.lineBreakMode = .byClipping
        addSubview(m_linkView);
        Layout.wrapH(m_linkView, l: 46, t: 22, width: width - (46 + 4));
        
        let linkMask = CAGradientLayer()
        linkMask.frame = CGRect(origin: .zero, size: m_linkView.measuredSize)
        linkMask.startPoint = CGPoint(x: 0, y: 0.5)
        linkMask.endPoint = CGPoint(x: 1, y: 0.5)
        linkMask.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
        linkMask.locations = [0.9, 1]
        m_linkView.layer.mask = linkMask
        
        m_openImage = UIImageView()
        addSubview(m_openImage)
        Layout.exact(m_openImage, width: H, height: H);
        
        m_cover = UIView()
        addSubview(m_cover)
        Layout.exact(m_cover, width: width, height: H);
        
        populate(title: "Loading...", link: "Loading...");
    }
    
    func populate(title:String, link:String){
        populate(title: title, link: link, colored: false);
    }
    
    func populate(title:String, link:String, colored:Bool){
        populate(title: title, link: link, colored: colored, callback: nil);
    }
    
    func populate(title:String, link:String, callback:ClickCallback?){
        populate(title: title, link: link, colored: true, callback: callback);
    }
    
    func populate(title:String, link:String, colored:Bool, callback:ClickCallback?){
    m_titleView.text = title
    m_linkView.text = link
    
    var color = Color.BLACK;
    var openImage = #imageLiteral(resourceName: "default_open")
    
        if let callback = callback{
            TouchController.setUniversalOnTouchListener(m_cover, allowSpreadMovement: true, whiteWhenOff: false, clickCallback: callback)
        }else{
            m_cover.touchListener = nil
        }
    
    if(colored){
    self.alpha = 1
    switch (m_colorTheme!){
    case TitleAndLinkView.LINK:
    color = Color.linkColor
    openImage = #imageLiteral(resourceName: "link_open")
    break;
    case TitleAndLinkView.YOUTUBE:
    color = Color.youtubeColor
    openImage = #imageLiteral(resourceName: "youtube_open")
    break;
    default:break;
    }
}else{
    self.alpha = 0.7
}

m_titleView.textColor = color
m_linkView.textColor = color
m_openImage.image = openImage
        setNeedsDisplay()
}
}
