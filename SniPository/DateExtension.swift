//
//  DateExtension.swift
//  SniPository
//
//  Created by Ivan Foong Kwok Keong on 5/6/17.
//  Copyright © 2017 ivanfoong. All rights reserved.
//

import Foundation

extension Date {
    
    var timeAgo: String {
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let secondsAgo = Int(Date().timeIntervalSince(self))
        if secondsAgo < 0            { return  "later"                           }
        if secondsAgo == 0           { return "now"                              }
        if secondsAgo == 1           { return "1 second ago"                     }
        if secondsAgo < minute       { return "\(secondsAgo) seconds ago"        }
        if secondsAgo < (2 * minute) { return "1 minute ago"                     }
        if secondsAgo < hour         { return "\(secondsAgo/minute) minutes ago" }
        if secondsAgo < 2 * hour     { return "1 hour ago"                       }
        if secondsAgo < day          { return "\(secondsAgo / hour) hours ago"   }
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        return formatter.string(from: self)
    }
    
}
