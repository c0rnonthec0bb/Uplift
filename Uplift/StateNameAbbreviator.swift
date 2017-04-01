//
//  StateNameAbbreviator.swift
//  Uplift
//
//  Created by Adam Cobb on 12/31/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import Foundation
import CoreLocation

class StateNameAbbreviator {
    
    static var mStateMap:[String:String] = [:];
    
    static func getStateAbbreviation(address:CLPlacemark)->String {
        
        populateStates();
        
        var stateCode:String?
        if let adminArea = address.administrativeArea{
            if let adminAbbr = mStateMap[adminArea]{
                stateCode = adminAbbr
            }else{
                stateCode = adminArea
            }
        }
        if let stateCode = stateCode{
            return stateCode
        }else{
            return ""
        }
    }
    
    static func populateStates() {
    if (mStateMap.isEmpty) {
    mStateMap["Alabama"] = "AL"
    mStateMap["Alaska"] = "AK"
    mStateMap["Alberta"] = "AB"
    mStateMap["American Samoa"] = "AS"
    mStateMap["Arizona"] = "AZ"
    mStateMap["Arkansas"] = "AR"
    mStateMap["Armed Forces (AE)"] = "AE"
    mStateMap["Armed Forces Americas"] = "AA"
    mStateMap["Armed Forces Pacific"] = "AP"
    mStateMap["British Columbia"] = "BC"
    mStateMap["California"] = "CA"
    mStateMap["Colorado"] = "CO"
    mStateMap["Connecticut"] = "CT"
    mStateMap["Delaware"] = "DE"
    mStateMap["District Of Columbia"] = "DC"
    mStateMap["Florida"] = "FL"
    mStateMap["Georgia"] = "GA"
    mStateMap["Guam"] = "GU"
    mStateMap["Hawaii"] = "HI"
    mStateMap["Idaho"] = "ID"
    mStateMap["Illinois"] = "IL"
    mStateMap["Indiana"] = "IN"
    mStateMap["Iowa"] = "IA"
    mStateMap["Kansas"] = "KS"
    mStateMap["Kentucky"] = "KY"
    mStateMap["Louisiana"] = "LA"
    mStateMap["Maine"] = "ME"
    mStateMap["Manitoba"] = "MB"
    mStateMap["Maryland"] = "MD"
    mStateMap["Massachusetts"] = "MA"
    mStateMap["Michigan"] = "MI"
    mStateMap["Minnesota"] = "MN"
    mStateMap["Mississippi"] = "MS"
    mStateMap["Missouri"] = "MO"
    mStateMap["Montana"] = "MT"
    mStateMap["Nebraska"] = "NE"
    mStateMap["Nevada"] = "NV"
    mStateMap["New Brunswick"] = "NB"
    mStateMap["New Hampshire"] = "NH"
    mStateMap["New Jersey"] = "NJ"
    mStateMap["New Mexico"] = "NM"
    mStateMap["New York"] = "NY"
    mStateMap["Newfoundland"] = "NF"
    mStateMap["North Carolina"] = "NC"
    mStateMap["North Dakota"] = "ND"
    mStateMap["Northwest Territories"] = "NT"
    mStateMap["Nova Scotia"] = "NS"
    mStateMap["Nunavut"] = "NU"
    mStateMap["Ohio"] = "OH"
    mStateMap["Oklahoma"] = "OK"
    mStateMap["Ontario"] = "ON"
    mStateMap["Oregon"] = "OR"
    mStateMap["Pennsylvania"] = "PA"
    mStateMap["Prince Edward Island"] = "PE"
    mStateMap["Puerto Rico"] = "PR"
    mStateMap["Quebec"] = "PQ"
    mStateMap["Rhode Island"] = "RI"
    mStateMap["Saskatchewan"] = "SK"
    mStateMap["South Carolina"] = "SC"
    mStateMap["South Dakota"] = "SD"
    mStateMap["Tennessee"] = "TN"
    mStateMap["Texas"] = "TX"
    mStateMap["Utah"] = "UT"
    mStateMap["Vermont"] = "VT"
    mStateMap["Virgin Islands"] = "VI"
    mStateMap["Virginia"] = "VA"
    mStateMap["Washington"] = "WA"
    mStateMap["West Virginia"] = "WV"
    mStateMap["Wisconsin"] = "WI"
    mStateMap["Wyoming"] = "WY"
    mStateMap["Yukon Territory"] = "YT"
    }
    }
}
