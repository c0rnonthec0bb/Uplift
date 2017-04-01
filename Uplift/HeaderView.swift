//
//  HeaderView.swift
//  Uplift
//
//  Created by Adam Cobb on 10/14/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class HeaderView : BasicViewGroup{
    
    weak var context:ViewController! = ViewController.context
    
    var profGroup:BasicViewGroup!
    var profCover:UIView!
    var prof:UIImageView!
    var locationText:UILabelX!, nameText:UILabelX!, timeText:UILabelX!
    var locationImage:UIImageView!, timeImage:UIImageView!
    var upliftView:UpliftView!
    
    var location:String? // "" = no location, null = current location
    var time:String? // null = no location
    
    static var H:CGFloat!
    let H:CGFloat = HeaderView.H
    
    required init(coder: NSCoder?) {
        super.init(coder: coder)
    }
    
    convenience init(){
        self.init(coder:nil);
        
        LayoutParams.alignParentLeftRight(subview: self)
        LayoutParams.setHeight(view: self, height: H)
        
        profGroup = BasicViewGroup()
        profGroup.backgroundColor = Color.view_touch
        self.addSubview(profGroup)
        
        profCover = UIView()
        self.addSubview(profCover)
        
        locationText = UILabelX()
        locationText.font = ViewController.typefaceM(11)
        locationText.textColor = Color.locationColor
        self.addSubview(locationText);
        
        locationImage = UIImageView()
        locationImage.image = #imageLiteral(resourceName: "location")
        locationImage.alpha = 0.5
        self.addSubview(locationImage);
        
        nameText = UILabelX()
        nameText.numberOfLines = 1
        nameText.textColor = Color.nameColor
        nameText.font = ViewController.typefaceM(14)
        self.addSubview(nameText);
        
        timeText = UILabelX()
        timeText.textColor = Color.timeColor
        timeText.font = ViewController.typefaceR(11)
        self.addSubview(timeText);
        
        timeImage = UIImageView()
        timeImage.image = #imageLiteral(resourceName: "time")
        timeImage.alpha = 0.5
        self.addSubview(timeImage);
        
        layoutChildren();
    }
    
    func populate(_ user:UserObject, _ l:String?, _ t:String?){
        populate(user.getName(), user.getThumb(), user.getThumbDimens(), l, t);
        TouchController.setUniversalOnTouchListener(nameText, allowSpreadMovement: true, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
            let _ = WindowWithUser(user: user)
        }))
        
        TouchController.setUniversalOnTouchListener(profCover, allowSpreadMovement: true, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
            let _ = WindowWithUser(user: user)
        }));
    }
    
    func populate(_ name:String?, _ profile:Data?, _ profileDimens:[Int]?, _ l:String?, _ t:String?){
        location = l;
        time = t;
        
        nameText.text = name
        
        timeText.text = time
        
        if(location == nil /* get current location */ || location != "" /* no location */) {
            
            if (location == nil) { //get current location
                context.locationViews.append(locationText)
                location = Files.readString("location", "Loading location...");
            }
            let index1 = location!.lastIndexOf(",");
            let index2 = Files.readString("location", "").lastIndexOf(",");
            if (index1 >= 0 && index2 >= 0 && location!.substring(index1) == Files.readString("location", "").substring(index2)) {
                location = location!.substring(0, index1);
            }
            locationText.text = location
        }
        
        prof = RecyclerImageView(profile, profileDimens!);
        profGroup.addSubview(prof);
        
        profGroup.backgroundColor = .clear
        
        layoutChildren();
    }
    
    func layoutChildren(){
        let profDimen = H - 8;
        let iconDimen:CGFloat = 14;
        Layout.exact(profGroup, l: 6, t: 4, width: profDimen, height: profDimen);
        Layout.exact(profCover, l: 6, t: 4, width: profDimen, height: profDimen);
        if let prof = prof {
            Layout.exact(prof, width: profDimen, height: profDimen);
        }
        if (location != nil) && location != "" {
            Layout.exact(locationImage, l: profDimen + 6 + 4, t: 6, width: iconDimen, height: iconDimen);
            Layout.wrap(locationText, l: profDimen + 6 + 4 + iconDimen, t: 6);
        }
        Layout.wrap(nameText, l: profDimen + 6 + 8, t: 20);
        if Measure.w(nameText) > context.screenWidth - 64 - 52{
            Layout.wrapH(nameText, l: profDimen + 6 + 8, t: 20, width: context.screenWidth - 64 - 52)
        }
        
        if(time != nil && time != ""){
            Layout.exact(timeImage, l: profDimen + iconDimen + Measure.w(locationText) + 6 + 4 + 6, t: 6, width: iconDimen, height: iconDimen);
            Layout.wrap(timeText, l: profDimen + iconDimen + Measure.w(locationText) + iconDimen + 6 + 4 + 6 + 2, t: 6);
        }
        if(upliftView != nil){
            upliftView.layoutChildren();
        }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        context.locationViews.remove(element: locationText)
    }
}

