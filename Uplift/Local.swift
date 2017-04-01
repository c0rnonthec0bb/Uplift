//
//  Local.swift
//  Uplift
//
//  Created by Adam Cobb on 9/6/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import Foundation
import Parse

open class Local {
    
    static func readAllOtherIndexedLists(_ mode:Int, _ submode:Int)->[String]{
        return readAllOtherIndexedLists(mode, submode, false);
    }
    
    static func readAllOtherIndexedLists(_ mode:Int, _ submode:Int, _ sortByUplifts:Bool)->[String]{
        var list:[String] = []
        
        for i in 0 ..< ViewController.context.modeNames.count{
            for j in 0 ..< ViewController.context.submodeNames[i].count{
    if(mode == i && submode == j) {
        let a = readList(i, j, !sortByUplifts)
        for i in stride(from: 0, to: min(readList(i, j, !sortByUplifts).count, readIndex(i, j, !sortByUplifts)), by: 1){
            list.append(a[i])
        }
    }else{
        let a = readList(i, j, false)
        for i in stride(from: 0, to: min(readList(i, j, false).count, readIndex(i, j, false)), by: 1){
            list.append(a[i])
        }
        let b = readList(i, j, true)
        for i in stride(from: 0, to: min(readList(i, j, true).count, readIndex(i, j, true)), by: 1){
            list.append(b[i])
        }
    }
    }
    }
    return list;
    }
    
    static func getIndexName(_ mode:Int, _ submode:Int, _ sortByUplifts:Bool)->String{
    var name = "";
    switch (mode){
    case 0:
    switch (submode){
    case 0:
    name = "local";
    break;
    case 1:
    name = "regional";
    break;
    case 2:
    name = "global";
    break;
    default: break;
    }
    break;
    case 1:
    switch (submode){
    case 0:
    break;
    case 1:
    break;
    default: break;
    }
    break;
    case 2:
    switch (submode){
    case 0:
    break;
    case 1:
    break;
    default: break;
    }
    break;
    case 3:
    break;
    default: break;
    }
    
    name += "Index";
    
    if(sortByUplifts){
    name += "2";
    }else{
    name += "1";
    }
    
    return name;
    }
    
    static func getListName(_ mode:Int, _ submode:Int, _ sortByUplifts:Bool)->String{
    var name = "";
    switch (mode){
    case 0:
    switch (submode){
    case 0:
    name = "local";
    break;
    case 1:
    name = "regional";
    break;
    case 2:
    name = "global";
    break;
    default: break;
    }
    break;
    case 1:
    switch (submode){
    case 0:
    name = "allUsers";
    break;
    case 1:
    name = "allPosts";
    break;
    default: break;
    }
    break;
    case 2:
    switch (submode){
    case 0:
    name = "notifications";
    break;
    case 1:
    name = "userPosts";
    break;
    default: break;
    }
    break;
    case 3:
    name = "settings";
    break;
    default: break;
    }
    
    name += "List";
    
    if(sortByUplifts){
    name += "2";
    }else{
    name += "1";
    }
    
    return name;
    }
    
    static func readIndex(_ mode:Int, _ submode:Int)->Int{ //when no sortByUpliftsNeeded
    return readIndex(mode, submode, false);
    }
    
    static func readIndex(_ mode:Int, _ submode:Int, _ sortByUplifts:Bool)->Int{
    return Files.readInteger(getIndexName(mode, submode, sortByUplifts), 0);
    }
    
    static func writeIndex(_ mode:Int, _ submode:Int, _ index:Int){ //when no sortByUpliftsNeeded
    writeIndex(mode, submode, false, index);
    }
    
    static func writeIndex(_ mode:Int, _ submode:Int, _ sortByUplifts:Bool, _ index:Int){
    Files.writeInteger(getIndexName(mode, submode, sortByUplifts), index);
    }
    
    static func readList(_ mode:Int, _ submode:Int) -> [String]{ //when no sortByUpliftsNeeded
    return readList(mode, submode, false);
    }
    
    static func readList(_ mode:Int, _ submode:Int, _ sortByUplifts:Bool)->[String]{
    return Files.readStringList(getListName(mode, submode, sortByUplifts), []);
    }
    
    static func writeList(_ mode:Int, _ submode:Int, _ value:[String]){ //when no sortByUpliftsNeeded
    writeList(mode, submode, false, value);
    }
    
    static func writeList(_ mode:Int, _ submode:Int, _ sortByUplifts:Bool, _ value:[String]){
    Files.writeStringList(getListName(mode, submode, sortByUplifts), value);
    }
    
    static func getCommentsIndexName(_ postId:String, _ sortByUplifts:Bool)->String{
    var name = postId + "Index";
    
    if(sortByUplifts){
    name += "2";
    }else{
    name += "1";
    }
    
    return name;
    }
    
    static func getCommentsListName(_ postId:String, _ sortByUplifts:Bool)->String{
    var name = postId + "List";
    
    if(sortByUplifts){
    name += "2";
    }else{
    name += "1";
    }
    
    return name;
    }
    
    static func readCommentsIndex(_ postId:String, _ sortByUplifts:Bool)->Int{
    return Files.readInteger(getCommentsIndexName(postId, sortByUplifts), 0);
    }
    
    static func writeCommentsIndex(_ postId:String, _ sortByUplifts:Bool, _ index:Int){
    Files.writeInteger(getCommentsIndexName(postId, sortByUplifts), index);
    }
    
    static func readCommentsList(_ postId:String, _ sortByUplifts:Bool)->[String]{
    return Files.readStringList(getCommentsListName(postId, sortByUplifts), []);
    }
    
    static func writeCommentsList(_ postId:String, _ sortByUplifts:Bool, _ value:[String]){
    Files.writeStringList(getCommentsListName(postId, sortByUplifts), value);
    }
    
    static func getCurrentGeoPoint()->PFGeoPoint{
    return PFGeoPoint(latitude: Files.readDouble("latitude", -90.0), longitude: Files.readDouble("longitude", 0));
    }
}
