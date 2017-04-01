//
//  UpliftView.swift
//  Uplift
//
//  Created by Adam Cobb on 10/14/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class UpliftView: BasicViewGroup {
    weak var context:ViewController! = ViewController.context
    
    var postId:String?
    var uplifted:Bool!
    var upliftsWithoutMe:Int!
    var text:UILabelX!
    var arrows:BasicViewGroup!
    var arrowgrey:UIImageView!, arrowgreen:UIImageView!, u:UIImageView!
    var parentW:CGFloat!
    
    required init(coder: NSCoder?) {
        super.init(coder: coder)
    }
    
    convenience init(postId:String?, uplifts:Int, upliftedInit:Bool, isComment:Bool){
        self.init(coder: nil)
    self.postId = postId;
    upliftsWithoutMe = uplifts;
    
    if(upliftedInit){
        upliftsWithoutMe! -= 1
    }
    
    text = UILabelX()
    ContentCreator.setUpBoldThemeStyle(text, size: 16, italics: false);
    text.textAlignment = .right
    addSubview(text);
    
    u = UIImageView()
    u.image = #imageLiteral(resourceName: "uplift_u")
    addSubview(u)
    
    arrows = BasicViewGroup();
    addSubview(arrows)
        
    arrowgrey = UIImageView()
    arrowgrey.image = #imageLiteral(resourceName: "uplift_arrowgrey")
    arrows.addSubview(arrowgrey);
    
        arrowgreen = UIImageView()
        arrowgreen.image = #imageLiteral(resourceName: "uplift_arrowgreen")
    arrows.addSubview(arrowgreen);
    
    arrowgreen.alpha = 0
    setUplift(newuplifted: upliftedInit);
        
        TouchController.setUniversalOnTouchListener(self, allowSpreadMovement: true, onOffCallback: OnOffCallback(on: {
            let _ = self.arrows.animate().scaleX(0.8).scaleY(0.8).setDuration(100).setInterpolator(.overshoot);
            let _ = self.u.animate().scaleX(0.8).scaleY(0.8).setDuration(100).setInterpolator(.overshoot);
        }, off: {
            let _ = self.arrows.animate().scaleX(1).scaleY(1).setDuration(300).setInterpolator(.overshoot);
            let _ = self.u.animate().scaleX(1).scaleY(1).setDuration(300).setInterpolator(.overshoot);
        }), clickCallback: ClickCallback(execute: {
            if let postId = postId{
                self.context.handleUplift(postId: postId, uplifted: !self.uplifted, isComment: isComment);
            }else{
                self.animateUplift(newuplifted: !self.uplifted);
            }
        }))
}

    func setUplift(newuplifted:Bool){
    uplifted = newuplifted;
    if uplifted! {
        text.text = String(upliftsWithoutMe + 1)
        layoutChildren();
        arrowgreen.alpha = 1
        arrows.translationY = 0
        u.alpha = 1
        u.isHiddenX = false
        arrowgreen.isHiddenX = false
        arrowgrey.isHiddenX = true
    } else {
        text.text = String(upliftsWithoutMe)
        layoutChildren();
        arrowgreen.alpha = 0
        arrows.translationY = 4
        u.alpha = 0
        u.isHiddenX = true
        arrowgreen.isHiddenX = true
        arrowgrey.isHiddenX = false
    }
}

    func animateUplift(newuplifted:Bool){
    
    arrowgreen.animate().cancel();
    
    u.isHiddenX = false
    arrowgreen.isHiddenX = false
    arrowgrey.isHiddenX = false
    
        let duration:Int64 = 400;
    
    uplifted = newuplifted;
    if uplifted! {
        text.text = String(upliftsWithoutMe + 1)
        layoutChildren();
        let _ = arrows.animate().translationY(0).setDuration(duration).setInterpolator(.overshoot);
        let _ = u.animate().alpha(1).setDuration(duration).setInterpolator(.linear);
        let _ = arrowgreen.animate().alpha(1).setDuration(duration).setInterpolator(.linear).setListener(AnimatorListener(onAnimationEnd: {
            self.arrowgrey.isHiddenX = true
        }))
    } else {
        text.text = String(upliftsWithoutMe)
        layoutChildren();
        let _ = arrows.animate().translationY(4).setDuration(duration).setInterpolator(.accelerate);
        let _ = u.animate().alpha(0).setDuration(duration).setInterpolator(.linear);
        let _ = arrowgreen.animate().alpha(0).setDuration(duration).setInterpolator(.linear).setListener(AnimatorListener(onAnimationEnd: {
            self.u.isHiddenX = true
            self.arrowgreen.isHiddenX = true
        }))
    }
}

func layoutChildren(){
    
    layoutTextAndSelf();
    
    let arrowDimen:CGFloat = 32
    
    Layout.exact(u, l: Measure.w(text), t: 6, width: arrowDimen, height: arrowDimen);
    Layout.exact(arrows, l: Measure.w(text), t: 6, width: arrowDimen, height: arrowDimen);
    Layout.exact(arrowgreen, width: arrowDimen, height: arrowDimen);
    Layout.exact(arrowgrey, width: arrowDimen, height: arrowDimen);
}

func layoutTextAndSelf(){
    let textDimens = Measure.wrap(text);
    let t = (HeaderView.H - textDimens.height) / 2;
    Layout.exact(text, l: 0, t: t, width: textDimens.width, height: textDimens.height);
    if(superview != nil) {
        Layout.exactLeft(self, r: parentW - 8, t: 0, width: textDimens.width + 32, height: HeaderView.H);
    }
}
}
