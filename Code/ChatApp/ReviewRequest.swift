//
//  ReviewRequest.swift
//  VCinity
//
//  Created by Tayal, Rishabh on 9/6/17.
//  Copyright © 2017 Rishabh Tayal. All rights reserved.
//

import UIKit
import StoreKit

class ReviewRequest: NSObject {
    
    static let runIncrementerSetting = "numberOfRuns"  // UserDefauls dictionary key where we store number of runs
    static let minimumRunCount = 5                     // Minimum number of runs that we should have until we ask for review
    
    public class func incrementAppRuns() {                   // counter for number of runs for the app. You can call this from App Delegate
        
        let usD = UserDefaults()
        let runs = getRunCounts() + 1
        usD.setValuesForKeys([runIncrementerSetting: runs])
        usD.synchronize()
        
    }
    
    class func getRunCounts () -> Int {               // Reads number of runs from UserDefaults and returns it.
        
        let usD = UserDefaults()
        let savedRuns = usD.value(forKey: runIncrementerSetting)
        
        var runs = 0
        if (savedRuns != nil) {
            
            runs = savedRuns as! Int
        }
        
        print("Run Counts are \(runs)")
        return runs
        
    }
    
    class func showReview() {
        
        let runs = getRunCounts()
        print("Show Review")
        
        if (runs > minimumRunCount) {
            
            if #available(iOS 10.3, *) {
                print("Review Requested")
                SKStoreReviewController.requestReview()
                
            } else {
                // Fallback on earlier versions
            }
            
        } else {
            
            print("Runs are now enough to request review!")
            
        }
        
    }
}
