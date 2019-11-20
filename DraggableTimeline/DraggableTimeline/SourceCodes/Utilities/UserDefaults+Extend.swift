//
//  UserDefaults+Extend.swift
//  DraggableTimeline
//
//  Created by industriousguy on 2019/11/20.
//  Copyright © 2019 industriousguy. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    static let AppleInterfaceThemeChanged = NSNotification.Name.init("AppleInterfaceThemeChangedNotification")
}

extension UserDefaults {
   
    func isDarkMode() -> Bool {
        if let dict = UserDefaults.standard.persistentDomain(forName: UserDefaults.globalDomain),
            let style = dict["AppleInterfaceStyle"] as? String {
            return style == "Dark" ? true : false
        }else {
            return false
        }
    }

}
