//
//  LabeledEditText.swift
//  Uplift
//
//  Created by Adam Cobb on 11/5/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class LabeledEditText: UIView {
    
    var fadingLabel:Bool!
    
    let editText = UIEditLabelX()
    let textView = UILabelX()
    let errorView = UILabelX()
    
    var labelScale:CGFloat!
    var labelScaled = false;
    
    var margin1:CGFloat!
    var margin2:CGFloat!
    
    override var isFirstResponder: Bool{ //iOS only
        get{
            return editText.isFirstResponder
        }
    }
    
    required init(coder:NSCoder?){
        
        if coder == nil{
            super.init(frame: CGRect(x: 0,y: 0,width: 0,height: 0))
        }else{
            super.init(coder: coder!)!
        }
    }
    convenience init(label:String, fadingLabel:Bool, textSize:CGFloat, labelSize:CGFloat, errorSize:CGFloat){
        self.init(coder: nil)
    
    self.fadingLabel = fadingLabel;
    
    labelScale = textSize / labelSize;
    
    margin1 = fadingLabel ? -labelSize * 1.2 : -labelSize * 0.8;
    margin2 = -errorSize * 0.8
    
        editText.textColor = Color.BLACK
        editText.font = ViewController.typefaceR(textSize)
        
        editText.onFocusChanged = { focused in
            
            if !self.errorOn{
                if focused{
                    self.editText.underlineColor = Color.theme
                }else{
                    self.editText.underlineColor = Color.halfBlack
                }
            }
            
            if ((focused || self.editText.text != "") && self.labelScaled) {
                let _ = self.textView.animate().translationY(0).translationX(0).scaleX(1).scaleY(1).alpha(fadingLabel ? 0 : 1).setDuration(200).setInterpolator(fadingLabel ? .linear : .decelerate);
                self.labelScaled = false;
            }
            
            if(!focused && self.editText.text == "" && !self.labelScaled){
                let _ = self.textView.animate().translationY((Measure.h(self.editText) + Measure.h(self.textView)) / 2 + self.margin1).translationX(Measure.w(self.textView) / 2 * (self.labelScale - 1)).scaleX(self.labelScale).scaleY(self.labelScale).alpha(1).setDuration(200).setInterpolator(.accelerate);
                self.labelScaled = true;
            }
        }
        
            editText.onTextChanged.append({ text in
                if (text == "") {
                    self.textView.textColor = Color.halfBlack
                    self.textView.layer.shadowOpacity = 0
                } else {
                    ContentCreator.setUpBoldThemeStyle(self.textView, size: labelSize, italics: false);
                }
            })
        
        addSubview(editText);
        
        textView.setInsets(UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4))
            textView.text = label
        textView.font = ViewController.typefaceM(labelSize)
addSubview(textView);

        errorView.setInsets(UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4))
            errorView.textColor = Color.flaggedColor
        errorView.font = ViewController.typefaceB(errorSize)
addSubview(errorView);

setText("");
setError("");
        
        //in place of onMeasure/onLayout:
        LayoutParams.alignParentTop(subview: textView)
        LayoutParams.alignParentLeftRight(subview: textView)
        
        LayoutParams.stackVertical(topView: textView, bottomView: editText, margin: margin1)
        LayoutParams.alignParentLeftRight(subview: editText)
        
        LayoutParams.stackVertical(topView: editText, bottomView: errorView, margin: margin2)
        LayoutParams.alignParentLeftRight(subview: errorView)
        
        LayoutParams.alignParentBottom(subview: errorView)
        
        ViewHelper.onDidLayoutSubviews[self] = {
                if(self.labelScaled){
                    self.textView.scaleX = self.labelScale
                    self.textView.scaleY = self.labelScale
                    self.textView.translationY = (Measure.h(self.editText) + Measure.h(self.textView)) / 2 + self.margin1
                    self.textView.translationX = Measure.w(self.textView) / 2 * (self.labelScale - 1)
                    self.textView.alpha = 1
                }else{
                    self.textView.translationY = 0
                    self.textView.translationX = 0
                    self.textView.scaleX = 1
                    self.textView.scaleY = 1
                    self.textView.alpha = fadingLabel ? 0 : 1
                }
        }
}

func setFocused(){
    labelScaled = false;
    let _ = editText.becomeFirstResponder()
    layoutIfNeeded()
}

func getText()->String{
    if let text = editText.text{
        return text
    }
    return ""
}

func setText(_ text:String){
    editText.text = text
    
    if(text == "" && !labelScaled && !editText.isFirstResponder){
        labelScaled = true;
        layoutIfNeeded()
    }
    
    if(text != "" && labelScaled){
        labelScaled = false;
        layoutIfNeeded()
    }
}
    
    var errorOn = false

func setError(_ error:String){
    errorView.text = error
    
    if(error == ""){
        errorOn = false
        if isFirstResponder{
            editText.underlineColor = Color.theme
        }else{
            editText.underlineColor = Color.halfBlack
        }
    }else{
        errorOn = true
        editText.underlineColor = Color.flaggedColor
    }
}
}




class LabeledEditField: UIView {
    
    var fadingLabel:Bool!
    
    let editText = UIEditFieldX()
    let textView = UILabelX()
    let errorView = UILabelX()
    
    var labelScale:CGFloat!
    var labelScaled = false;
    
    var margin1:CGFloat!
    var margin2:CGFloat!
    
    override var isFirstResponder: Bool{ //iOS only
        get{
            return editText.isFirstResponder
        }
    }
    
    required init(coder:NSCoder?){
        
        if coder == nil{
            super.init(frame: CGRect(x: 0,y: 0,width: 0,height: 0))
        }else{
            super.init(coder: coder!)!
        }
    }
    convenience init(label:String, fadingLabel:Bool, textSize:CGFloat, labelSize:CGFloat, errorSize:CGFloat){
        self.init(coder: nil)
        
        self.fadingLabel = fadingLabel;
        
        labelScale = textSize / labelSize;
        
        margin1 = fadingLabel ? -labelSize * 1.2 : -labelSize * 0.8;
        margin2 = -errorSize * 0.8
        
        editText.textColor = Color.BLACK
        editText.font = ViewController.typefaceR(textSize)
        
        editText.onFocusChanged = { focused in
            
            if !self.errorOn{
                if focused{
                    self.editText.underlineColor = Color.theme
                }else{
                    self.editText.underlineColor = Color.halfBlack
                }
            }
            
            if ((focused || self.editText.text != "") && self.labelScaled) {
                let _ = self.textView.animate().translationY(0).translationX(0).scaleX(1).scaleY(1).alpha(fadingLabel ? 0 : 1).setDuration(200).setInterpolator(fadingLabel ? .linear : .decelerate);
                self.labelScaled = false;
            }
            
            if(!focused && self.editText.text == "" && !self.labelScaled){
                let _ = self.textView.animate().translationY((Measure.h(self.editText) + Measure.h(self.textView)) / 2 + self.margin1).translationX(Measure.w(self.textView) / 2 * (self.labelScale - 1)).scaleX(self.labelScale).scaleY(self.labelScale).alpha(1).setDuration(200).setInterpolator(.accelerate);
                self.labelScaled = true;
            }
        }
        
        editText.onTextChanged.append({ text in
            if (text == "") {
                self.textView.textColor = Color.halfBlack
                self.textView.layer.shadowOpacity = 0
            } else {
                ContentCreator.setUpBoldThemeStyle(self.textView, size: labelSize, italics: false);
            }
        })
        
        addSubview(editText);
        
        textView.setInsets(UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4))
        textView.text = label
        textView.font = ViewController.typefaceM(labelSize)
        addSubview(textView);
        
        errorView.setInsets(UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4))
        errorView.textColor = Color.flaggedColor
        errorView.font = ViewController.typefaceB(errorSize)
        addSubview(errorView);
        
        setText("");
        setError("");
        
        //in place of onMeasure/onLayout:
        LayoutParams.alignParentTop(subview: textView)
        LayoutParams.alignParentLeftRight(subview: textView)
        
        LayoutParams.stackVertical(topView: textView, bottomView: editText, margin: margin1)
        LayoutParams.alignParentLeftRight(subview: editText)
        
        LayoutParams.stackVertical(topView: editText, bottomView: errorView, margin: margin2)
        LayoutParams.alignParentLeftRight(subview: errorView)
        
        LayoutParams.alignParentBottom(subview: errorView)
        
        ViewHelper.onDidLayoutSubviews[self] = {
            if(self.labelScaled){
                self.textView.scaleX = self.labelScale
                self.textView.scaleY = self.labelScale
                self.textView.translationY = (Measure.h(self.editText) + Measure.h(self.textView)) / 2 + self.margin1
                self.textView.translationX = Measure.w(self.textView) / 2 * (self.labelScale - 1)
                self.textView.alpha = 1
            }else{
                self.textView.translationY = 0
                self.textView.translationX = 0
                self.textView.scaleX = 1
                self.textView.scaleY = 1
                self.textView.alpha = fadingLabel ? 0 : 1
            }
        }
    }
    
    func setFocused(){
        labelScaled = false;
        let _ = editText.becomeFirstResponder()
        layoutIfNeeded()
    }
    
    func getText()->String{
        if let text = editText.text{
            return text
        }
        return ""
    }
    
    func setText(_ text:String){
        editText.text = text
        
        if(text == "" && !labelScaled && !editText.isFirstResponder){
            labelScaled = true;
            layoutIfNeeded()
        }
        
        if(text != "" && labelScaled){
            labelScaled = false;
            layoutIfNeeded()
        }
    }
    
    var errorOn = false
    
    func setError(_ error:String){
        errorView.text = error
        
        if(error == ""){
            errorOn = false
            if isFirstResponder{
                editText.underlineColor = Color.theme
            }else{
                editText.underlineColor = Color.halfBlack
            }
        }else{
            errorOn = true
            editText.underlineColor = Color.flaggedColor
        }
    }
}

