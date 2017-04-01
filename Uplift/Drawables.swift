//
//  Drawables.swift
//  Uplift
//
//  Created by Adam Cobb on 11/30/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class Drawables {
    static func theme_gradient()->UIImage{
        let size = CGSize(width: ViewController.context.screenWidth, height: ViewController.context.menuH)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = [Color.theme.cgColor, Color("#00783C").cgColor]
        
        UIGraphicsBeginImageContext(size);
        let context = UIGraphicsGetCurrentContext()!
        context.drawLinearGradient(CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0, 1])!, start: .zero, end: CGPoint(x: 0, y: size.height), options: CGGradientDrawingOptions(rawValue: 0))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return image
    }
    
    static func shadow_gradient()->UIImage{
        
        let size = CGSize(width: ViewController.context.screenWidth, height: 6)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = [Color("#0000").cgColor, Color.black.cgColor]
        
        UIGraphicsBeginImageContext(size);
        let context = UIGraphicsGetCurrentContext()!
        context.drawLinearGradient(CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0, 1])!, start: .zero, end: CGPoint(x: 0, y: size.height), options: CGGradientDrawingOptions(rawValue: 0))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return image
    }
    
    static func switch_front()->UIImage{
        let size = CGSize(width: 24, height: 24) * UIScreen.main.scale * 4
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = [Color.theme_bold.cgColor, Color("#00a050").cgColor]
        
        let bottomRect = CGRect(x: 0.6, y: 0.6, width: size.width - 0.6, height: CGFloat(size.height) - 0.6)
        let topRect = CGRect(x: 0, y: 0, width: CGFloat(size.width) - 0.6, height: CGFloat(size.height) - 0.6)
        let topCenter = CGPoint(x: topRect.width / 2, y: topRect.height / 2)
        
        UIGraphicsBeginImageContext(size);
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(Color.theme.cgColor)
        context.fillEllipse(in: bottomRect)
        context.drawRadialGradient(CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0.0,1.0])!, startCenter: topCenter, startRadius: 0, endCenter: topCenter, endRadius: topRect.width / 2, options: CGGradientDrawingOptions(rawValue: 0))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return image
    }
    
    static func refresh_dot()->UIImage{
        let size = CGSize(width: 14, height: 14) * UIScreen.main.scale * 4
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = [Color.theme.cgColor, Color.theme_0_875.cgColor]
        
        UIGraphicsBeginImageContext(size);
        let context = UIGraphicsGetCurrentContext()!
        context.drawRadialGradient(CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0.0,1.0])!, startCenter: CGPoint(x: size.width / 2, y: size.height / 2), startRadius: 0, endCenter: CGPoint(x: size.width / 2, y: size.height / 2), endRadius: size.width / 2, options: CGGradientDrawingOptions(rawValue: 0))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return image
    }
    
    static func circle_white()->UIImage{
        let size = CGSize(width: 50, height: 50) * UIScreen.main.scale * 4
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = [Color("#fff").cgColor, Color("#bbb").cgColor]
        
        UIGraphicsBeginImageContext(size);
        let context = UIGraphicsGetCurrentContext()!
        context.drawRadialGradient(CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0.0,1.0])!, startCenter: CGPoint(x: size.width / 2, y: size.height / 2), startRadius: 0, endCenter: CGPoint(x: size.width / 2, y: size.height / 2), endRadius: size.width / 2, options: CGGradientDrawingOptions(rawValue: 0))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return image
    }
    
    static func circle_white_shadow()->UIImage{
        var size = CGSize(width: UIScreen.main.scale * 200, height: UIScreen.main.scale * 200)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = [Color("#fff").cgColor, Color("#bbb").cgColor]
        
        var bottomRect = CGRect(x: 10, y: 10, width: size.width - 10, height: CGFloat(size.height) - 10)
        var topRect = CGRect(x: 5, y: 5, width: CGFloat(size.width) - 10, height: CGFloat(size.height) - 10)
        var topCenter = CGPoint(x: topRect.width / 2, y: topRect.height / 2)
        
        size = size * 4
        bottomRect = bottomRect * 4
        topRect = topRect * 4
        topCenter = topCenter * 4
        
        UIGraphicsBeginImageContext(size);
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(Color.theme_0_75.cgColor)
        context.fillEllipse(in: bottomRect)
        context.drawRadialGradient(CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0.0,1.0])!, startCenter: topCenter, startRadius: 0, endCenter: topCenter, endRadius: topRect.width / 2, options: CGGradientDrawingOptions(rawValue: 0))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return image
    }
}
